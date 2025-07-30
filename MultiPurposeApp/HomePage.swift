import SwiftUI
import Foundation

// List Model
struct ListItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let createdAt: Date
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
}

struct HomePage: View {
    let user: TempUser
    let onLogout: () -> Void
    @State private var selectedTab: Int = 0
    @State private var showAddListSheet: Bool = false
    @State private var newListName: String = ""
    @State private var lists: [ListItem] = []
    @State private var deletedLists: [ListItem] = []
    @State private var selectedList: ListItem? = nil
    @State private var listsNeedRefresh = false
    @State private var pendingDeleteList: ListItem? = nil
    @State private var pendingRestoreList: ListItem? = nil
    @State private var pendingPermanentDeleteList: ListItem? = nil
    @State private var showGitHubSync: Bool = false
    @State private var showiCloudSync: Bool = false
    
    var sortedLists: [ListItem] {
        lists.sorted { $0.createdAt > $1.createdAt }
    }
    
    var sortedDeletedLists: [ListItem] {
        deletedLists.sorted { $0.createdAt > $1.createdAt }
    }
    
    var activeListCount: Int {
        lists.reduce(0) { count, list in
            guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else {
                return count
            }
            if let decoded = try? JSONDecoder().decode([ListElement].self, from: data), !decoded.isEmpty {
                return count + 1
            }
            return count
        }
    }
    
    // MARK: - Statistics Computed Properties
    
    var totalItemsCount: Int {
        lists.reduce(0) { count, list in
            guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else {
                return count
            }
            if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
                return count + decoded.count
            }
            return count
        }
    }
    
    var completedItemsCount: Int {
        lists.reduce(0) { count, list in
            guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else {
                return count
            }
            if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
                return count + decoded.filter { $0.purchased }.count
            }
            return count
        }
    }
    
    var overallCompletionRate: Double {
        guard totalItemsCount > 0 else { return 0 }
        return Double(completedItemsCount) / Double(totalItemsCount)
    }
    
    var listsWithItemsCount: Int {
        lists.reduce(0) { count, list in
            guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else {
                return count
            }
            if let decoded = try? JSONDecoder().decode([ListElement].self, from: data), !decoded.isEmpty {
                return count + 1
            }
            return count
        }
    }
    
    var averageItemsPerList: Double {
        guard lists.count > 0 else { return 0 }
        return Double(totalItemsCount) / Double(lists.count)
    }
    
    var mostRecentList: ListItem? {
        lists.max { $0.createdAt < $1.createdAt }
    }
    
    var listsCreatedThisWeek: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return lists.filter { $0.createdAt >= oneWeekAgo }.count
    }
    
    var listsCreatedThisMonth: Int {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return lists.filter { $0.createdAt >= oneMonthAgo }.count
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                
                //Lists Tab
                VStack(spacing: 20) {
                    if lists.isEmpty {
                        //default display when empty list
                        Spacer()
                        Label("Lists", systemImage: "list.bullet.rectangle")
                            .font(.title)
                        
                        VStack(spacing: 5) {
                            Text("List is empty !")
                                .foregroundColor(.secondary)
                            Text("Add a new list using + button !")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        VStack {
                            // Summary / navigation bar above scrollable area
                            HStack {
                                Text("Summary: ")
                                    .bold()
                                Spacer()
                                Text("Total Lists: \(lists.count)")
                                    .foregroundColor(.green)
                                    .bold()
                                Spacer()
                                Text("Active: \(activeListCount)")
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                            .font(.callout)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            List(sortedLists) { list in
                                ListCardView(list: list, refreshKey: listsNeedRefresh)
                                    .onTapGesture {
                                        selectedList = list
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            pendingDeleteList = list
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                            .listStyle(.plain)
                            .id(listsNeedRefresh)
                        }
                    }
                }
                .tabItem {
                    Label("Lists", systemImage: "list.bullet.rectangle")
                }
                .tag(0)
                
                
                //Deleted Tab
                VStack(spacing: 20) {
                    if deletedLists.isEmpty {
                        //default display when empty deleted list
                        Spacer()
                        Label("Deleted Lists", systemImage: "trash")
                            .font(.title)
                        
                        VStack(spacing: 5) {
                            Text("No deleted lists !")
                                .foregroundColor(.secondary)
                            Text("Deleted lists will appear here")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        VStack {
                            // Summary / navigation bar above scrollable area
                            HStack {
                                Text("Summary: ")
                                    .bold()
                                Spacer()
                                Text("Deleted Lists: \(deletedLists.count)")
                                    .foregroundColor(.red)
                                    .bold()
                            }
                            .font(.callout)
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            List(sortedDeletedLists) { list in
                                ListCardView(list: list, refreshKey: listsNeedRefresh)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            pendingRestoreList = list
                                        } label: {
                                            Label("Restore", systemImage: "arrow.uturn.left")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            pendingPermanentDeleteList = list
                                        } label: {
                                            Label("Delete Forever", systemImage: "trash.fill")
                                        }
                                    }
                            }
                            .listStyle(.plain)
                            .id(listsNeedRefresh)
                        }
                    }
                }
                .tabItem {
                    Label("Deleted", systemImage: "trash")
                }
                .tag(1)
                
                
                //Stats Tab
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Label("Statistics", systemImage: "chart.bar.xaxis")
                                .font(.title)
                                .bold()
                            Text("Your list management insights")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Overview Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // Total Lists Card
                            StatCard(
                                title: "Total Lists",
                                value: "\(lists.count)",
                                icon: "list.bullet.rectangle",
                                color: .blue
                            )
                            
                            // Active Lists Card
                            StatCard(
                                title: "Active Lists",
                                value: "\(activeListCount)",
                                icon: "checklist",
                                color: .green
                            )
                            
                            // Total Items Card
                            StatCard(
                                title: "Total Items",
                                value: "\(totalItemsCount)",
                                icon: "square.and.pencil",
                                color: .orange
                            )
                            
                            // Completed Items Card
                            StatCard(
                                title: "Completed",
                                value: "\(completedItemsCount)",
                                icon: "checkmark.circle",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                        
                        // Progress Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress Overview")
                                .font(.headline)
                                .bold()
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                // Overall Completion
                                ProgressStatCard(
                                    title: "Overall Completion",
                                    value: overallCompletionRate,
                                    subtitle: "\(completedItemsCount) of \(totalItemsCount) items",
                                    color: .blue
                                )
                                
                                // Lists with Items
                                if lists.count > 0 {
                                    ProgressStatCard(
                                        title: "Lists with Items",
                                        value: Double(listsWithItemsCount) / Double(lists.count),
                                        subtitle: "\(listsWithItemsCount) of \(lists.count) lists",
                                        color: .green
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.headline)
                                .bold()
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                // This Week
                                ActivityStatCard(
                                    title: "This Week",
                                    value: "\(listsCreatedThisWeek)",
                                    subtitle: "lists created",
                                    icon: "calendar.badge.clock",
                                    color: .orange
                                )
                                
                                // This Month
                                ActivityStatCard(
                                    title: "This Month",
                                    value: "\(listsCreatedThisMonth)",
                                    subtitle: "lists created",
                                    icon: "calendar",
                                    color: .purple
                                )
                                
                                // Average Items
                                if lists.count > 0 {
                                    ActivityStatCard(
                                        title: "Average Items",
                                        value: String(format: "%.1f", averageItemsPerList),
                                        subtitle: "per list",
                                        icon: "chart.bar",
                                        color: .blue
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Recent List Section
                        if let recentList = mostRecentList {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Most Recent List")
                                    .font(.headline)
                                    .bold()
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    RecentListCard(list: recentList)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Deleted Lists Summary
                        if deletedLists.count > 0 {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Deleted Lists")
                                    .font(.headline)
                                    .bold()
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    DeletedSummaryCard(count: deletedLists.count)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
                
                
                //Profile Tab
                ScrollView {
                    VStack(spacing: 24) {
                        // User Info Section
                        VStack(spacing: 16) {
                            // Profile Header
                            VStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue)
                                
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.title2)
                                    .bold()
                                
                                Text(user.userId)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 20)
                            
                            // User Details
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
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                                                // Data Backup Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Data Backup")
                                .font(.headline)
                                .bold()
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                // GitHub Sync Button
                                Button {
                                    showGitHubSync = true
                                } label: {
                                    HStack {
                                        Image(systemName: "cloud.and.arrow.up")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        
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
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                
                                // iCloud Sync Button
                                Button {
                                    showiCloudSync = true
                                } label: {
                                    HStack {
                                        Image(systemName: "icloud")
                                            .font(.title2)
                                            .foregroundColor(.green)
                                        
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
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // App Info Section
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
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Logout Section
                        VStack(spacing: 16) {
                            Button("Log Out") {
                                logout()
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
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea()
            .fullScreenCover(item: $selectedList, onDismiss: {
                selectedList = nil
                loadLists()
                listsNeedRefresh.toggle()
            }) { list in
                ListItemsView(list: list)
            }
            
            if selectedTab == 0 {
                Button {
                    showAddListSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 60)
                .padding(.trailing, 45)
                .sheet(isPresented: $showAddListSheet) {
                    VStack(spacing: 24) {
                        Text("Create New List")
                            .font(.title2)
                            .bold()
                            .padding(.top, 32)
                        ZStack(alignment: .trailing) {
                            TextField("Enter List Name", text: $newListName)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            if !newListName.isEmpty {
                                Button(action: { newListName = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 16)
                            }
                        }
                        .padding(.horizontal)
                        
                        Button("Create List") {
                            createNewList()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .alert("Delete List?", isPresented: Binding(get: { pendingDeleteList != nil }, set: { if !$0 { pendingDeleteList = nil } })) {
            Button("Delete", role: .destructive) {
                if let listToDelete = pendingDeleteList {
                    deleteList(listToDelete)
                    pendingDeleteList = nil
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteList = nil
            }
        } message: {
            Text("This list will be moved to the Deleted tab. You can restore it later.")
        }
        .alert("Restore List?", isPresented: Binding(get: { pendingRestoreList != nil }, set: { if !$0 { pendingRestoreList = nil } })) {
            Button("Restore") {
                if let listToRestore = pendingRestoreList {
                    restoreList(listToRestore)
                    pendingRestoreList = nil
                }
            }
            Button("Cancel", role: .cancel) {
                pendingRestoreList = nil
            }
        } message: {
            Text("This list will be restored to the main Lists tab.")
        }
        .alert("Delete Forever?", isPresented: Binding(get: { pendingPermanentDeleteList != nil }, set: { if !$0 { pendingPermanentDeleteList = nil } })) {
            Button("Delete Forever", role: .destructive) {
                if let listToDelete = pendingPermanentDeleteList {
                    permanentDeleteList(listToDelete)
                    pendingPermanentDeleteList = nil
                }
            }
            Button("Cancel", role: .cancel) {
                pendingPermanentDeleteList = nil
            }
        } message: {
            Text("This action cannot be undone. The list and all its items will be permanently deleted.")
        }
        .onAppear {
            loadLists()
            loadDeletedLists()
        }
        .sheet(isPresented: $showGitHubSync) {
            GitHubSyncView(
                user: user,
                lists: lists,
                deletedLists: deletedLists,
                onDataRestored: { backupData in
                    restoreFromBackup(backupData)
                }
            )
        }
        .sheet(isPresented: $showiCloudSync) {
            iCloudSyncView(
                user: user,
                lists: lists,
                deletedLists: deletedLists,
                onDataRestored: { appData in
                    restoreFromiCloud(appData)
                }
            )
        }
    }
    
    private func createNewList() {
        let trimmedName = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newList = ListItem(name: trimmedName)
        lists.append(newList)
        
        // Save lists to UserDefaults
        saveLists()
        
        // Clear input and dismiss sheet
        newListName = ""
        showAddListSheet = false
    }
    
    private func logout() {
        // Clear any user-specific data if needed
        // For now, we'll just call the logout callback
        onLogout()
    }
    
    // MARK: - Data Persistence
    
    private func saveLists() {
        do {
            let encoded = try JSONEncoder().encode(lists)
            UserDefaults.standard.set(encoded, forKey: "lists_\(user.userId)")
        } catch {
            print("Failed to save lists: \(error)")
        }
    }
    
    private func saveDeletedLists() {
        do {
            let encoded = try JSONEncoder().encode(deletedLists)
            UserDefaults.standard.set(encoded, forKey: "deletedLists_\(user.userId)")
        } catch {
            print("Failed to save deleted lists: \(error)")
        }
    }
    
    private func loadLists() {
        guard let data = UserDefaults.standard.data(forKey: "lists_\(user.userId)") else {
            lists = []
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([ListItem].self, from: data)
            lists = decoded
        } catch {
            print("Failed to load lists: \(error)")
            lists = []
        }
    }
    
    private func loadDeletedLists() {
        guard let data = UserDefaults.standard.data(forKey: "deletedLists_\(user.userId)") else {
            deletedLists = []
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([ListItem].self, from: data)
            deletedLists = decoded
        } catch {
            print("Failed to load deleted lists: \(error)")
            deletedLists = []
        }
    }
    
    private func deleteList(_ list: ListItem) {
        // Remove the list from the lists array
        lists.removeAll { $0.id == list.id }
        // Add to deleted lists
        deletedLists.append(list)
        // Save updated lists and deleted lists
        saveLists()
        saveDeletedLists()
        // Refresh UI
        listsNeedRefresh.toggle()
    }
    
    private func restoreList(_ list: ListItem) {
        // Remove from deleted lists
        deletedLists.removeAll { $0.id == list.id }
        // Add back to active lists
        lists.append(list)
        // Save updated lists and deleted lists
        saveLists()
        saveDeletedLists()
        // Refresh UI
        listsNeedRefresh.toggle()
    }
    
    private func permanentDeleteList(_ list: ListItem) {
        // Remove from deleted lists
        deletedLists.removeAll { $0.id == list.id }
        // Remove associated items from UserDefaults
        UserDefaults.standard.removeObject(forKey: "items_\(list.id.uuidString)")
        // Save updated deleted lists
        saveDeletedLists()
        // Refresh UI
        listsNeedRefresh.toggle()
    }
    
    // MARK: - GitHub Sync
    
    private func restoreFromBackup(_ backupData: BackupData) {
        // Restore lists
        lists = backupData.lists
        saveLists()
        
        // Restore deleted lists
        deletedLists = backupData.deletedLists
        saveDeletedLists()
        
        // Restore items for each list
        for (listId, items) in backupData.items {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "items_\(listId)")
            }
        }
        
        // Refresh UI
        listsNeedRefresh.toggle()
    }
    
    // MARK: - iCloud Sync
    
    private func restoreFromiCloud(_ appData: AppData) {
        // Restore lists
        lists = appData.lists
        saveLists()
        
        // Restore deleted lists
        deletedLists = appData.deletedLists
        saveDeletedLists()
        
        // Restore items for each list
        for (listId, items) in appData.items {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "items_\(listId)")
            }
        }
        
        // Refresh UI
        listsNeedRefresh.toggle()
    }
}

// List Card View
struct ListCardView: View {
    let list: ListItem
    let refreshKey: Bool
    
    private var hasItems: Bool {
        guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else {
            return false
        }
        if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
            return !decoded.isEmpty
        }
        return false
    }
    
    private var itemsCount: Int {
        guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else { return 0 }
        if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
            return decoded.count
        }
        return 0
    }
    private var purchasedCount: Int {
        guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else { return 0 }
        if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
            return decoded.filter { $0.purchased }.count
        }
        return 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            
            HStack(spacing: 15) {
                Text(list.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                if hasItems {
                    Image(systemName: "checklist")
                        .foregroundColor(.blue)
                }
            }
                
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(list.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(list.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(itemsCount) / \(purchasedCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Statistics View Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: Double
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.headline)
                    .bold()
                    .foregroundColor(color)
            }
            
            ProgressView(value: value)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ActivityStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct RecentListCard: View {
    let list: ListItem
    
    private var itemsCount: Int {
        guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else { return 0 }
        if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
            return decoded.count
        }
        return 0
    }
    
    private var purchasedCount: Int {
        guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else { return 0 }
        if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
            return decoded.filter { $0.purchased }.count
        }
        return 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Created \(list.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(itemsCount) items")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.blue)
                    
                    Text("\(purchasedCount) completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            if itemsCount > 0 {
                ProgressView(value: Double(purchasedCount) / Double(itemsCount))
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DeletedSummaryCard: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Deleted Lists")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(count)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.red)
                    
                    Text("lists")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("Check Deleted tab to restore")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HomePage(user: .default, onLogout: {})
}
