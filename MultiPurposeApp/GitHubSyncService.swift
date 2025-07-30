//
//  GitHubSyncService.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - GitHub Sync Models

struct GitHubGist: Codable {
    let id: String?
    let description: String
    let isPublic: Bool
    let files: [String: GistFile]
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case isPublic = "public"
        case files
    }
    
    init(description: String, isPublic: Bool, files: [String: GistFile]) {
        self.id = nil
        self.description = description
        self.isPublic = isPublic
        self.files = files
    }
}

struct GistFile: Codable {
    let content: String
    let filename: String
    
    init(content: String, filename: String) {
        self.content = content
        self.filename = filename
    }
}

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let avatar_url: String?
}

// MARK: - GitHub Sync Service

class GitHubSyncService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    
    private let baseURL = "https://api.github.com"
    private var accessToken: String?
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    enum SyncError: Error, LocalizedError {
        case invalidToken
        case networkError
        case authenticationFailed
        case dataEncodingError
        case dataDecodingError
        case gistNotFound
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .invalidToken:
                return "Invalid GitHub access token"
            case .networkError:
                return "Network connection error"
            case .authenticationFailed:
                return "GitHub authentication failed"
            case .dataEncodingError:
                return "Failed to encode data for backup"
            case .dataDecodingError:
                return "Failed to decode backup data"
            case .gistNotFound:
                return "Backup not found on GitHub"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
    
    // MARK: - Authentication
    
    func authenticate(with token: String) async throws {
        isLoading = true
        syncStatus = .syncing
        
        defer {
            isLoading = false
        }
        
        let url = URL(string: "\(baseURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SyncError.networkError
            }
            
            if httpResponse.statusCode == 200 {
                let _ = try JSONDecoder().decode(GitHubUser.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = token
                    self.isAuthenticated = true
                    self.syncStatus = .success
                }
            } else {
                throw SyncError.authenticationFailed
            }
        } catch {
            DispatchQueue.main.async {
                self.syncStatus = .error(error.localizedDescription)
            }
            throw error
        }
    }
    
    func logout() {
        accessToken = nil
        isAuthenticated = false
        lastSyncDate = nil
        syncStatus = .idle
    }
    
    // MARK: - Data Backup
    
    func backupData(user: TempUser, lists: [ListItem], deletedLists: [ListItem]) async throws {
        guard let token = accessToken else {
            throw SyncError.invalidToken
        }
        
        isLoading = true
        syncStatus = .syncing
        
        defer {
            isLoading = false
        }
        
        // Prepare backup data
        let backupData = BackupData(
            user: user,
            lists: lists,
            deletedLists: deletedLists,
            items: getAllItems(for: lists),
            timestamp: Date()
        )
        
        // Encode backup data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let jsonData = try? encoder.encode(backupData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw SyncError.dataEncodingError
        }
        
        // Create or update gist
        let gistDescription = "MultiPurposeApp Backup - \(user.firstName) \(user.lastName)"
        let filename = "multipurposeapp_backup_\(user.userId.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_")).json"
        
        let gistFile = GistFile(content: jsonString, filename: filename)
        let gist = GitHubGist(description: gistDescription, isPublic: false, files: [filename: gistFile])
        
        // Try to find existing gist first
        if let existingGistId = await findExistingGist(token: token, user: user) {
            try await updateGist(token: token, gistId: existingGistId, gist: gist)
        } else {
            try await createGist(token: token, gist: gist)
        }
        
        DispatchQueue.main.async {
            self.lastSyncDate = Date()
            self.syncStatus = .success
        }
    }
    
    // MARK: - Data Restore
    
    func restoreData(for user: TempUser) async throws -> BackupData? {
        guard let token = accessToken else {
            throw SyncError.invalidToken
        }
        
        isLoading = true
        syncStatus = .syncing
        
        defer {
            isLoading = false
        }
        
        guard let gistId = await findExistingGist(token: token, user: user) else {
            throw SyncError.gistNotFound
        }
        
        let url = URL(string: "\(baseURL)/gists/\(gistId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw SyncError.networkError
            }
            
            let gist = try JSONDecoder().decode(GitHubGist.self, from: data)
            
            // Find the backup file
            guard let backupFile = gist.files.values.first(where: { $0.filename.contains("multipurposeapp_backup") }) else {
                throw SyncError.gistNotFound
            }
            
            // Decode backup data
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backupData = try decoder.decode(BackupData.self, from: Data(backupFile.content.utf8))
            
            DispatchQueue.main.async {
                self.lastSyncDate = Date()
                self.syncStatus = .success
            }
            
            return backupData
        } catch {
            DispatchQueue.main.async {
                self.syncStatus = .error(error.localizedDescription)
            }
            throw error
        }
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
    
    private func findExistingGist(token: String, user: TempUser) async -> String? {
        let url = URL(string: "\(baseURL)/gists")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            let gists = try JSONDecoder().decode([GitHubGist].self, from: data)
            
            // Find gist with matching description
            let userDescription = "MultiPurposeApp Backup - \(user.firstName) \(user.lastName)"
            return gists.first { $0.description == userDescription }?.id
        } catch {
            return nil
        }
    }
    
    private func createGist(token: String, gist: GitHubGist) async throws {
        let url = URL(string: "\(baseURL)/gists")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(gist)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw SyncError.networkError
        }
    }
    
    private func updateGist(token: String, gistId: String, gist: GitHubGist) async throws {
        let url = URL(string: "\(baseURL)/gists/\(gistId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(gist)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SyncError.networkError
        }
    }
}

// MARK: - Backup Data Model

struct BackupData: Codable {
    let user: TempUser
    let lists: [ListItem]
    let deletedLists: [ListItem]
    let items: [String: [ListElement]] // listId -> items
    let timestamp: Date
    let version: String
    
    init(user: TempUser, lists: [ListItem], deletedLists: [ListItem], items: [String: [ListElement]], timestamp: Date) {
        self.user = user
        self.lists = lists
        self.deletedLists = deletedLists
        self.items = items
        self.timestamp = timestamp
        self.version = "1.0.0"
    }
} 