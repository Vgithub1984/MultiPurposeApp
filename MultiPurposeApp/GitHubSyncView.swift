//
//  GitHubSyncView.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//

import SwiftUI

struct GitHubSyncView: View {
    let user: TempUser
    let lists: [ListItem]
    let deletedLists: [ListItem]
    let onDataRestored: (BackupData) -> Void
    
    @StateObject private var syncService = GitHubSyncService()
    @State private var accessToken: String = ""
    @State private var showTokenAlert = false
    @State private var showBackupAlert = false
    @State private var showRestoreAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "cloud.and.arrow.up")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("GitHub Sync")
                            .font(.title)
                            .bold()
                        
                        Text("Backup and restore your data to GitHub")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Authentication Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Authentication")
                            .font(.headline)
                            .bold()
                        
                        if syncService.isAuthenticated {
                            // Authenticated State
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Connected to GitHub")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
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
                                
                                Button("Disconnect") {
                                    syncService.logout()
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            // Not Authenticated State
                            VStack(spacing: 12) {
                                Text("Enter your GitHub Personal Access Token")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                SecureField("GitHub Access Token", text: $accessToken)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Connect to GitHub") {
                                    authenticateWithGitHub()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(accessToken.isEmpty)
                                
                                Button("How to get a token?") {
                                    showTokenAlert = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sync Actions Section
                    if syncService.isAuthenticated {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sync Actions")
                                .font(.headline)
                                .bold()
                            
                            VStack(spacing: 12) {
                                // Backup Button
                                Button {
                                    backupData()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.up.to.icloud")
                                            .font(.title2)
                                        VStack(alignment: .leading) {
                                            Text("Backup to GitHub")
                                                .font(.headline)
                                            Text("Upload your current data")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if syncService.isLoading {
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
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(syncService.isLoading)
                                
                                // Restore Button
                                Button {
                                    restoreData()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.down.from.icloud")
                                            .font(.title2)
                                        VStack(alignment: .leading) {
                                            Text("Restore from GitHub")
                                                .font(.headline)
                                            Text("Download your backup")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if syncService.isLoading {
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
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(syncService.isLoading)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Status Section
                    if syncService.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Syncing with GitHub...")
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
                                .foregroundColor(.green)
                            Text("Sync completed successfully")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    case .error(let message):
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    default:
                        EmptyView()
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("GitHub Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("GitHub Access Token", isPresented: $showTokenAlert) {
            Button("OK") { }
        } message: {
            Text("1. Go to GitHub.com and sign in\n2. Go to Settings > Developer settings > Personal access tokens\n3. Generate a new token with 'gist' permissions\n4. Copy the token and paste it here")
        }
        .alert("Backup Data", isPresented: $showBackupAlert) {
            Button("Backup", role: .destructive) {
                Task {
                    await performBackup()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will upload your current data to GitHub. Any existing backup will be updated.")
        }
        .alert("Restore Data", isPresented: $showRestoreAlert) {
            Button("Restore", role: .destructive) {
                Task {
                    await performRestore()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will replace your current data with the backup from GitHub. This action cannot be undone.")
        }
    }
    
    // MARK: - Actions
    
    private func authenticateWithGitHub() {
        Task {
            do {
                try await syncService.authenticate(with: accessToken)
            } catch {
                DispatchQueue.main.async {
                    alertMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func backupData() {
        showBackupAlert = true
    }
    
    private func restoreData() {
        showRestoreAlert = true
    }
    
    private func performBackup() async {
        do {
            try await syncService.backupData(user: user, lists: lists, deletedLists: deletedLists)
        } catch {
            DispatchQueue.main.async {
                alertMessage = error.localizedDescription
            }
        }
    }
    
    private func performRestore() async {
        do {
            if let backupData = try await syncService.restoreData(for: user) {
                DispatchQueue.main.async {
                    onDataRestored(backupData)
                }
            }
        } catch {
            DispatchQueue.main.async {
                alertMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    GitHubSyncView(
        user: .default,
        lists: [],
        deletedLists: [],
        onDataRestored: { _ in }
    )
} 