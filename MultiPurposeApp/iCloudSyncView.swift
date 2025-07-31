//
//  iCloudSyncView.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//

import SwiftUI

struct iCloudSyncView: View {
    let user: TempUser
    let lists: [ListItem]
    let deletedLists: [ListItem]
    let onDataRestored: (AppData) -> Void
    
    @StateObject private var syncService = iCloudSyncService()
    @State private var showBackupAlert = false
    @State private var showRestoreAlert = false
    @State private var showSettingsAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "icloud")
                            .font(.system(size: 60))
                            .foregroundColor(Color.appPrimary)
                        
                        Text("iCloud Sync")
                            .font(.title)
                            .bold()
                        
                        Text("Automatically sync your data across devices")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // iCloud Status Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("iCloud Status")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        if syncService.isAvailable {
                            // iCloud Available
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.appSuccess)
                                    Text("iCloud is available")
                                        .font(.subheadline)
                                        .foregroundColor(Color.appSuccess)
                                    Spacer()
                                }
                                
                                if let lastSync = syncService.lastSyncDate {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.secondary)
                                        Text("Last sync: \(lastSync, style: .relative)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }
                                
                                Button("Check Status") {
                                    syncService.checkiCloudStatus()
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(Color.appPrimary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            // iCloud Not Available
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Color.appWarning)
                                    Text("iCloud not available")
                                        .font(.subheadline)
                                        .foregroundColor(Color.appWarning)
                                    Spacer()
                                }
                                
                                Text("Please sign in to iCloud in Settings to enable sync")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                                Button("Open Settings") {
                                    showSettingsAlert = true
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(Color.appPrimary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sync Actions Section
                    if syncService.isAvailable {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sync Actions")
                                .font(.headline)
                                .bold()
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                // Backup Button
                                Button {
                                    backupData()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.up.to.icloud")
                                            .font(.title2)
                                        VStack(alignment: .leading) {
                                            Text("Backup to iCloud")
                                                .font(.headline)
                                            Text("Upload your current data")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if syncService.isSyncing {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(syncService.isSyncing)
                                
                                // Restore Button
                                Button {
                                    restoreData()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.down.from.icloud")
                                            .font(.title2)
                                        VStack(alignment: .leading) {
                                            Text("Restore from iCloud")
                                                .font(.headline)
                                            Text("Download your backup")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if syncService.isSyncing {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appSuccess.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(syncService.isSyncing)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Status Section
                    if syncService.isSyncing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Syncing with iCloud...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Sync Status
                    switch syncService.syncStatus {
                    case .success:
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.appSuccess)
                            Text("Sync completed successfully")
                                .font(.subheadline)
                                .foregroundColor(Color.appSuccess)
                        }
                        .padding()
                                                    .background(Color.appSuccess.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    case .error(let message):
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color.appError)
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(Color.appError)
                        }
                        .padding()
                                                    .background(Color.appError.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    default:
                        EmptyView()
                    }
                    
                    // Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About iCloud Sync")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(
                                icon: "checkmark.circle",
                                title: "Automatic Sync",
                                description: "Data syncs automatically across your devices"
                            )
                            
                            InfoRow(
                                icon: "lock.shield",
                                title: "Secure",
                                description: "Your data is encrypted and secure in iCloud"
                            )
                            
                            InfoRow(
                                icon: "wifi",
                                title: "Offline Support",
                                description: "Works offline, syncs when connected"
                            )
                            
                            InfoRow(
                                icon: "chart.bar",
                                title: "Storage Limit",
                                description: "1MB per data item (sufficient for lists)"
                            )
                        }
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.appGroupedBackground)
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Backup Data", isPresented: $showBackupAlert) {
            Button("Backup", role: .destructive) {
                Task {
                    await performBackup()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will upload your current data to iCloud. It will automatically sync across your devices.")
        }
        .alert("Restore Data", isPresented: $showRestoreAlert) {
            Button("Restore", role: .destructive) {
                Task {
                    await performRestore()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will replace your current data with the backup from iCloud. This action cannot be undone.")
        }
        .alert("Open Settings", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You'll be taken to Settings where you can sign in to iCloud and enable iCloud Drive.")
        }
    }
    
    // MARK: - Actions
    
    private func backupData() {
        showBackupAlert = true
    }
    
    private func restoreData() {
        showRestoreAlert = true
    }
    
    private func performBackup() async {
        do {
            try await syncService.syncUserData(user, lists: lists, deletedLists: deletedLists)
        } catch {
            // Error is handled by the service
        }
    }
    
    private func performRestore() async {
        do {
            if let appData = try await syncService.loadUserData(for: user) {
                DispatchQueue.main.async {
                    onDataRestored(appData)
                }
            }
        } catch {
            // Error is handled by the service
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    iCloudSyncView(
        user: .default,
        lists: [],
        deletedLists: [],
        onDataRestored: { _ in }
    )
} 