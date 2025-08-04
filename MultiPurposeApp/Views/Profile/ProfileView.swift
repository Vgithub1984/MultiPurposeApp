import SwiftUI

struct ProfileView: View {
    let user: TempUser
    let onLogout: () -> Void
    let lists: [ListItem]
    let deletedLists: [ListItem]
    
    // MARK: - Sheet States
    @State private var showAccountSheet = false
    @State private var showPrivacySheet = false
    @State private var showNotificationsSheet = false
    @State private var showStorageSheet = false
    @State private var showHelpSheet = false
    @State private var showAboutSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("First Name:")
                                .bold()
                            Spacer()
                            Text(user.firstName)
                        }
                        HStack {
                            Text("Last Name:")
                                .bold()
                            Spacer()
                            Text(user.lastName)
                        }
                        HStack {
                            Text("User ID:")
                                .bold()
                            Spacer()
                            Text(user.userId)
                        }
                    }
                    .padding()
                    .appCardStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                // MARK: - Settings Menu
                VStack(alignment: .leading, spacing: 16) {
                    Text("Settings")
                        .font(.headline)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        // Account
                        MenuButton(
                            icon: "person.circle",
                            title: "Account",
                            subtitle: "Manage your account settings",
                            color: .blue
                        ) {
                            showAccountSheet = true
                        }
                        
                        // Privacy
                        MenuButton(
                            icon: "lock.shield",
                            title: "Privacy",
                            subtitle: "Control your privacy settings",
                            color: .green
                        ) {
                            showPrivacySheet = true
                        }
                        
                        // Notifications
                        MenuButton(
                            icon: "bell",
                            title: "Notifications",
                            subtitle: "Configure notification preferences",
                            color: .orange
                        ) {
                            showNotificationsSheet = true
                        }
                        
                        // Storage and Data
                        MenuButton(
                            icon: "externaldrive",
                            title: "Storage and Data",
                            subtitle: "Manage app storage and data usage",
                            color: .purple
                        ) {
                            showStorageSheet = true
                        }
                        
                        // Help
                        MenuButton(
                            icon: "questionmark.circle",
                            title: "Help",
                            subtitle: "Get help and support",
                            color: .cyan
                        ) {
                            showHelpSheet = true
                        }
                        
                        // About Me
                        MenuButton(
                            icon: "info.circle",
                            title: "About Me",
                            subtitle: "App information and version details",
                            color: .gray
                        ) {
                            showAboutSheet = true
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    Button("Log Out") {
                        onLogout()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        // MARK: - Sheet Presentations
        .fullScreenCover(isPresented: $showAccountSheet) {
            AccountSheet(user: user)
        }
        .fullScreenCover(isPresented: $showPrivacySheet) {
            PrivacySheet()
        }
        .fullScreenCover(isPresented: $showNotificationsSheet) {
            NotificationsSheet()
        }
        .fullScreenCover(isPresented: $showStorageSheet) {
            StorageSheet(lists: lists, deletedLists: deletedLists)
        }
        .fullScreenCover(isPresented: $showHelpSheet) {
            HelpSheet()
        }
        .fullScreenCover(isPresented: $showAboutSheet) {
            AboutSheet()
        }
    }
}

// MARK: - Menu Button Component
struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sheet Views
struct AccountSheet: View {
    let user: TempUser
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Account Settings")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(spacing: 16) {
                        ProfileInfoRow(title: "First Name", value: user.firstName)
                        ProfileInfoRow(title: "Last Name", value: user.lastName)
                        ProfileInfoRow(title: "User ID", value: user.userId)
                        ProfileInfoRow(title: "Account Type", value: "Standard")
                        ProfileInfoRow(title: "Member Since", value: "July 2025")
                        ProfileInfoRow(title: "Last Login", value: "Today")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct PrivacySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allowAnalytics = true
    @State private var allowCrashReports = true
    @State private var allowPersonalization = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Privacy Settings")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(spacing: 16) {
                        Toggle("Allow Analytics", isOn: $allowAnalytics)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        Toggle("Allow Crash Reports", isOn: $allowCrashReports)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        Toggle("Allow Personalization", isOn: $allowPersonalization)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Privacy Statement Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Statement")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            PrivacyStatementItem(
                                title: "Data Collection",
                                description: "MultiPurposeApp collects only the data you create within the app. We do not collect personal information, location data, or device identifiers."
                            )
                            
                            PrivacyStatementItem(
                                title: "Local Storage",
                                description: "All your lists and items are stored locally on your device using UserDefaults. We do not have access to your personal data."
                            )
                            
                            PrivacyStatementItem(
                                title: "Cloud Sync",
                                description: "Optional cloud synchronization uses your personal iCloud or GitHub account. We cannot access data stored in your personal cloud accounts."
                            )
                            
                            PrivacyStatementItem(
                                title: "Third-Party Services",
                                description: "We do not share your data with third-party services, advertisers, or analytics providers without your explicit consent."
                            )
                            
                            PrivacyStatementItem(
                                title: "Data Deletion",
                                description: "You can delete all your data at any time by deleting the app. Your data is not stored on our servers."
                            )
                            
                            PrivacyStatementItem(
                                title: "Children's Privacy",
                                description: "Our app does not knowingly collect personal information from children under 13. If you are a parent and believe your child has provided us with personal information, please contact us."
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allowPushNotifications = true
    @State private var allowReminders = true
    @State private var allowUpdates = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "bell")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Notification Settings")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(spacing: 16) {
                        Toggle("Push Notifications", isOn: $allowPushNotifications)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        Toggle("Reminders", isOn: $allowReminders)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        Toggle("App Updates", isOn: $allowUpdates)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct StorageSheet: View {
    let lists: [ListItem]
    let deletedLists: [ListItem]
    @Environment(\.dismiss) private var dismiss
    
    private var totalLists: Int {
        lists.count + deletedLists.count
    }
    
    private var totalItems: Int {
        var count = 0
        for list in lists {
            if let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)"),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                count += items.count
            }
        }
        return count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "externaldrive")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Storage and Data")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(spacing: 16) {
                        ProfileInfoRow(title: "Active Lists", value: "\(lists.count)")
                        ProfileInfoRow(title: "Deleted Lists", value: "\(deletedLists.count)")
                        ProfileInfoRow(title: "Total Lists", value: "\(totalLists)")
                        ProfileInfoRow(title: "Total Items", value: "\(totalItems)")
                        ProfileInfoRow(title: "App Size", value: "2.4 MB")
                        ProfileInfoRow(title: "Data Usage", value: "156 KB")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("Storage and Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.cyan)
                        
                        Text("Help & Support")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(spacing: 16) {
                        HelpItem(
                            icon: "plus.circle",
                            title: "Creating Lists",
                            description: "Tap the + button to create a new list. Give it a name and start adding items."
                        )
                        
                        HelpItem(
                            icon: "checkmark.circle",
                            title: "Marking Items",
                            description: "Tap on any item to mark it as purchased. Tap again to unmark."
                        )
                        
                        HelpItem(
                            icon: "trash",
                            title: "Deleting Items",
                            description: "Swipe left on an item or tap the trash icon to delete it."
                        )
                        
                        HelpItem(
                            icon: "arrow.left",
                            title: "Swipe Gestures",
                            description: "Swipe left on lists to delete them. Swipe right on deleted lists to restore."
                        )
                    }
                    .padding(.horizontal)
                    
                    // Contact Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Support")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ContactItem(
                                icon: "envelope",
                                title: "Email Support",
                                value: "support@multipurposeapp.com",
                                action: "Send Email"
                            )
                            
                            ContactItem(
                                icon: "phone",
                                title: "Phone Support",
                                value: "+1 (555) 123-4567",
                                action: "Call Now"
                            )
                            
                            ContactItem(
                                icon: "globe",
                                title: "Website",
                                value: "www.multipurposeapp.com",
                                action: "Visit Website"
                            )
                            
                            ContactItem(
                                icon: "clock",
                                title: "Support Hours",
                                value: "Mon-Fri: 9AM-6PM EST",
                                action: "Check Status"
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("About MultiPurposeApp")
                            .font(.title2)
                            .bold()
                    }
                    
                    // App Introduction Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Introduction")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        Text("MultiPurposeApp is a comprehensive list management solution designed to help you organize your life efficiently. Whether you're managing shopping lists, task lists, or any other type of organized information, our app provides the tools you need to stay productive and organized.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Core Features Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Core Features")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            FeatureItem(
                                icon: "list.bullet.rectangle",
                                title: "Smart List Management",
                                description: "Create, organize, and manage multiple lists with intuitive swipe gestures and easy navigation."
                            )
                            
                            FeatureItem(
                                icon: "checkmark.circle",
                                title: "Item Tracking",
                                description: "Mark items as completed, track progress, and maintain organized item status across all your lists."
                            )
                            
                            FeatureItem(
                                icon: "chart.bar.xaxis",
                                title: "Advanced Analytics",
                                description: "Get detailed insights into your productivity with comprehensive statistics and completion tracking."
                            )
                            
                            FeatureItem(
                                icon: "icloud",
                                title: "Cloud Synchronization",
                                description: "Sync your data across devices using iCloud or GitHub for seamless access anywhere."
                            )
                            
                            FeatureItem(
                                icon: "trash",
                                title: "Smart Deletion",
                                description: "Safely delete lists and items with the ability to restore them from the deleted items section."
                            )
                            
                            FeatureItem(
                                icon: "person.crop.circle",
                                title: "User Profiles",
                                description: "Personalized experience with user accounts, settings, and customizable preferences."
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // App Information Section
                    VStack(spacing: 16) {
                        ProfileInfoRow(title: "Version", value: "1.0.0")
                        ProfileInfoRow(title: "Build", value: "MVP")
                        ProfileInfoRow(title: "Platform", value: "iOS 17.0+")
                        ProfileInfoRow(title: "Developer", value: "MultiPurposeApp Team")
                        ProfileInfoRow(title: "Release Date", value: "July 2025")
                        ProfileInfoRow(title: "License", value: "MIT")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("About MultiPurposeApp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                    }
                }
            }
        }
        .background(Color.white)
    }
}

// MARK: - Helper Components
struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct HelpItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PrivacyStatementItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct ContactItem: View {
    let icon: String
    let title: String
    let value: String
    let action: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Action would be implemented here
            }) {
                Text(action)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

