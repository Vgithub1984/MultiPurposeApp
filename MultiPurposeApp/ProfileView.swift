import SwiftUI

struct ProfileView: View {
    let user: TempUser
    let onLogout: () -> Void
    let lists: [ListItem]
    let deletedLists: [ListItem]
    var showGitHubSync: Binding<Bool>
    var showiCloudSync: Binding<Bool>

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

                VStack(alignment: .leading, spacing: 16) {
                    Text("Data Backup")
                        .font(.headline)
                        .bold()
                        .padding(.horizontal)
                    VStack(spacing: 12) {
                        Button {
                            showGitHubSync.wrappedValue = true
                        } label: {
                            HStack {
                                Image(systemName: "cloud.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(Color.appPrimary)
                                VStack(alignment: .leading) {
                                    Text("GitHub Sync")
                                        .font(.headline)
                                    Text("Manual backup to GitHub")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .appCardStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                        )
                        Button {
                            showiCloudSync.wrappedValue = true
                        } label: {
                            HStack {
                                Image(systemName: "icloud")
                                    .font(.title2)
                                    .foregroundColor(Color.appSuccess)
                                VStack(alignment: .leading) {
                                    Text("iCloud Sync")
                                        .font(.headline)
                                    Text("Automatic sync across devices")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .appCardStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appSuccess.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("App Information")
                        .font(.headline)
                        .bold()
                        .padding(.horizontal)
                    VStack(spacing: 12) {
                        HStack {
                            Text("Version:")
                                .bold()
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Build:")
                                .bold()
                            Spacer()
                            Text("MVP")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Platform:")
                                .bold()
                            Spacer()
                            Text("iOS 17.0+")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .appCardStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appSecondaryText.opacity(0.3), lineWidth: 1)
                    )
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
    }
}
