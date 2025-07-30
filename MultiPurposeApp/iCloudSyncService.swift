//
//  iCloudSyncService.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - iCloud Sync Service

class iCloudSyncService: ObservableObject {
    @Published var isAvailable = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    private let notificationCenter = NotificationCenter.default
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    enum SyncError: Error, LocalizedError {
        case iCloudNotAvailable
        case dataEncodingError
        case dataDecodingError
        case syncFailed
        case quotaExceeded
        
        var errorDescription: String? {
            switch self {
            case .iCloudNotAvailable:
                return "iCloud is not available. Please sign in to iCloud in Settings."
            case .dataEncodingError:
                return "Failed to encode data for iCloud sync"
            case .dataDecodingError:
                return "Failed to decode data from iCloud"
            case .syncFailed:
                return "iCloud sync failed. Please try again."
            case .quotaExceeded:
                return "iCloud storage quota exceeded"
            }
        }
    }
    
    init() {
        setupiCloudSync()
    }
    
    // MARK: - Setup and Configuration
    
    private func setupiCloudSync() {
        // Check if iCloud is available
        isAvailable = FileManager.default.ubiquityIdentityToken != nil
        
        if isAvailable {
            // Observe iCloud changes
            notificationCenter.addObserver(
                self,
                selector: #selector(ubiquitousKeyValueStoreDidChange),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: iCloudStore
            )
            
            // Synchronize with iCloud
            iCloudStore.synchronize()
        }
    }
    
    @objc private func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.handleiCloudChanges(notification)
        }
    }
    
    private func handleiCloudChanges(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keysForChange = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }
        
        // Handle changes for specific keys
        for key in keysForChange {
            handleKeyChange(key)
        }
        
        syncStatus = .success
        lastSyncDate = Date()
    }
    
    private func handleKeyChange(_ key: String) {
        // Notify observers about the change
        notificationCenter.post(name: .iCloudDataChanged, object: nil, userInfo: ["key": key])
    }
    
    // MARK: - Data Operations
    
    func saveData<T: Codable>(_ data: T, forKey key: String) throws {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }
        
        isSyncing = true
        syncStatus = .syncing
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            
            // Check data size (iCloud KVS has 1MB limit per key)
            if jsonData.count > 1_000_000 {
                throw SyncError.quotaExceeded
            }
            
            iCloudStore.set(jsonData, forKey: key)
            
            // Synchronize with iCloud
            if iCloudStore.synchronize() {
                DispatchQueue.main.async {
                    self.syncStatus = .success
                    self.lastSyncDate = Date()
                    self.isSyncing = false
                }
            } else {
                throw SyncError.syncFailed
            }
        } catch {
            DispatchQueue.main.async {
                self.syncStatus = .error(error.localizedDescription)
                self.isSyncing = false
            }
            throw error
        }
    }
    
    func loadData<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }
        
        guard let jsonData = iCloudStore.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(type, from: jsonData)
            return data
        } catch {
            throw SyncError.dataDecodingError
        }
    }
    
    func deleteData(forKey key: String) throws {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }
        
        iCloudStore.removeObject(forKey: key)
        
        if !iCloudStore.synchronize() {
            throw SyncError.syncFailed
        }
    }
    
    // MARK: - App-Specific Sync Methods
    
    func syncUserData(_ user: TempUser, lists: [ListItem], deletedLists: [ListItem]) async throws {
        let userData = AppData(
            user: user,
            lists: lists,
            deletedLists: deletedLists,
            items: getAllItems(for: lists),
            timestamp: Date(),
            version: "1.0.0"
        )
        
        try saveData(userData, forKey: "appData_\(user.userId)")
    }
    
    func loadUserData(for user: TempUser) async throws -> AppData? {
        return try loadData(AppData.self, forKey: "appData_\(user.userId)")
    }
    
    func syncListItems(_ items: [ListElement], forListId listId: String) async throws {
        try saveData(items, forKey: "items_\(listId)")
    }
    
    func loadListItems(forListId listId: String) async throws -> [ListElement]? {
        return try loadData([ListElement].self, forKey: "items_\(listId)")
    }
    
    // MARK: - Helper Methods
    
    private func getAllItems(for lists: [ListItem]) -> [String: [ListElement]] {
        var allItems: [String: [ListElement]] = [:]
        
        for list in lists {
            if let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)"),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                allItems[list.id.uuidString] = items
            }
        }
        
        return allItems
    }
    
    // MARK: - Status and Monitoring
    
    func checkiCloudStatus() {
        isAvailable = FileManager.default.ubiquityIdentityToken != nil
        
        if isAvailable {
            iCloudStore.synchronize()
        }
    }
    
    func getStorageUsage() -> (used: Int64, total: Int64) {
        // Note: iCloud KVS doesn't provide direct storage usage info
        // This is a placeholder for future implementation
        return (0, 0)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - App Data Model

struct AppData: Codable {
    let user: TempUser
    let lists: [ListItem]
    let deletedLists: [ListItem]
    let items: [String: [ListElement]]
    let timestamp: Date
    let version: String
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let iCloudDataChanged = Notification.Name("iCloudDataChanged")
} 