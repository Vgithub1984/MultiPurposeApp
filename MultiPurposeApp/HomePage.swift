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

    // Focus state for the new list name TextField in the add list sheet
    @FocusState private var isListNameFieldFocused: Bool

    
    var sortedLists: [ListItem] {
        lists.sorted { $0.createdAt > $1.createdAt }
    }
    
    var sortedDeletedLists: [ListItem] {
        deletedLists.sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Cached Statistics Properties
    @State private var cachedStats: StatisticsCache = StatisticsCache()
    
    var activeListCount: Int {
        cachedStats.activeListCount
    }
    
    var totalItemsCount: Int {
        cachedStats.totalItemsCount
    }
    
    var completedItemsCount: Int {
        cachedStats.completedItemsCount
    }
    
    var overallCompletionRate: Double {
        cachedStats.overallCompletionRate
    }
    
    var listsWithItemsCount: Int {
        cachedStats.listsWithItemsCount
    }
    
    var averageItemsPerList: Double {
        cachedStats.averageItemsPerList
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
        var count = 0
        for list in lists {
            if list.createdAt >= oneMonthAgo {
                count += 1
            }
        }
        return count
    }
    
    var body: some View {
        // Main ZStack containing all tabs and floating add button
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                listsTabView
                deletedTabView
                statsTabView
                profileTabView
            }
            .background(Color.appBackground)
            .ignoresSafeArea()
            .fullScreenCover(item: $selectedList, onDismiss: {
                selectedList = nil
                loadLists()
                listsNeedRefresh.toggle()
            }) { list in
                ListItemsView(list: list)
            }
            // Floating add button for new lists
            if selectedTab == 0 {
                addListButton
            }
        }
        // --- ALERTS & SHEETS (must be inside body) ---
        // Alert for deleting a list (moves to Deleted tab)
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
        // Alert for restoring a deleted list
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
        // Alert for permanent deletion
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
        // Load lists and deleted lists on appear
        .onAppear {
            loadLists()
            loadDeletedLists()
        }

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
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                        .focused($isListNameFieldFocused) // Bind focus state to the TextField
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
            .onAppear {
                // Automatically focus the list name TextField when sheet appears
                isListNameFieldFocused = true
            }
        }
    }
    

    
    private var listsTabView: some View {
            VStack(spacing: 20) {
                if lists.isEmpty {
                    //default display when empty list
                    Spacer()
                    VStack(spacing: 5) {
                        Label("Lists", systemImage: "list.bullet.rectangle")
                        .font(.title)
                        .bold()
                        Text("List is empty !")
                            .foregroundColor(.secondary)
                        Text("Add a new list using + button !")
                            .foregroundColor(.secondary)
                        Text("")
                        Text("")
                        Text("Gestures:")
                            .font(.title)
                            .bold()
                        Label("Swipe Left to Delete List", systemImage: "arrow.backward.square")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    VStack {
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
                        .environment(\.defaultMinListRowHeight, 0)
                        .environment(\.defaultMinListHeaderHeight, 0)
                        .listRowSeparator(.hidden)
                        .id(listsNeedRefresh)
                    }
                }
            }
            .tabItem {
                Label("Lists", systemImage: "list.bullet.rectangle")
            }
            .tag(0)
            .badge(lists.count)
        }
        
        private var deletedTabView: some View {
            VStack(spacing: 20) {
                if deletedLists.isEmpty {
                    //default display when empty deleted list
                    Spacer()
                    VStack(spacing: 5) {
                        Label("Deleted Lists", systemImage: "trash")
                            .font(.title)
                            .bold()
                        Text("No deleted lists !")
                            .foregroundColor(.secondary)
                        Text("Deleted lists will appear here")
                            .foregroundColor(.secondary)
                        Text("")
                        Text("")
                        Text("Gestures:")
                            .font(.title)
                            .bold()
                        Label("Swipe Left to Delete List", systemImage: "arrow.backward.square")
                            .foregroundColor(.secondary)
                        Label("Swipe Right to Restore List", systemImage: "arrow.forward.square")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    VStack {
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
                        .environment(\.defaultMinListRowHeight, 0)
                        .environment(\.defaultMinListHeaderHeight, 0)
                        .listRowSeparator(.hidden)
                        .id(listsNeedRefresh)
                    }
                }
            }
            .tabItem {
                Label("Deleted", systemImage: "trash")
            }
            .tag(1)
            .badge(deletedLists.count)
        }
        
        private var statsTabView: some View {
            ScrollView {
                StatsView(
                    lists: lists,
                   // activeListCount: activeListCount,
                    totalItemsCount: totalItemsCount,
                    completedItemsCount: completedItemsCount,
                    overallCompletionRate: overallCompletionRate,
                    listsWithItemsCount: listsWithItemsCount,
                    averageItemsPerList: averageItemsPerList,
                    mostRecentList: mostRecentList,
                    listsCreatedThisWeek: listsCreatedThisWeek,
                    listsCreatedThisMonth: listsCreatedThisMonth,
                    deletedLists: deletedLists
                )
            }
            .background(Color(.systemGroupedBackground))
            .tabItem {
                Label("Stats", systemImage: "chart.bar.xaxis")
            }
            .tag(2)
        }
        
        private var profileTabView: some View {
            ProfileView(
                user: user,
                onLogout: onLogout,
                lists: lists,
                deletedLists: deletedLists
            )
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(3)
        }
        
        private var addListButton: some View {
            Button {
                showAddListSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.appPrimary)
            }
            .padding(.bottom, 60)
            .padding(.trailing, 45)
        }
    
    private func createNewList() {
        let trimmedName = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newList = ListItem(name: trimmedName)
        lists.append(newList)
        
        // Save lists to UserDefaults
        saveLists()
        
        // Update statistics
        updateStatistics()
        
        // Clear input and dismiss sheet
        newListName = ""
        showAddListSheet = false
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
            updateStatistics()
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([ListItem].self, from: data)
            lists = decoded
            updateStatistics()
        } catch {
            print("Failed to load lists: \(error)")
            lists = []
            updateStatistics()
        }
    }
    
    private func updateStatistics() {
        DispatchQueue.global(qos: .userInitiated).async {
            let stats = StatisticsCache.calculate(from: self.lists)
            DispatchQueue.main.async {
                self.cachedStats = stats
            }
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
        // Update statistics
        updateStatistics()
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
        // Update statistics
        updateStatistics()
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
    

}
// End of HomePage struct

// List Card View
struct ListCardView: View {
    let list: ListItem
    let refreshKey: Bool
    @State private var cachedItems: [ListElement] = []
    
    private var hasItems: Bool {
        !cachedItems.isEmpty
    }
    
    private var itemsCount: Int {
        cachedItems.count
    }
    
    private var purchasedCount: Int {
        cachedItems.filter { $0.purchased }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            
            HStack(spacing: 8) {
                Text(list.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if itemsCount >= 1 && purchasedCount != itemsCount {
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                if purchasedCount == itemsCount && itemsCount != 0 {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
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
                Text("\(purchasedCount) / \(itemsCount)")
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
        .onAppear {
            loadCachedItems()
        }
        .onChange(of: refreshKey) { _, _ in
            loadCachedItems()
        }
    }
    
    private func loadCachedItems() {
        if let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)"),
           let items = try? JSONDecoder().decode([ListElement].self, from: data) {
            cachedItems = items
        } else {
            cachedItems = []
        }
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
    @State private var cachedItems: [ListElement] = []
    
    private var itemsCount: Int {
        cachedItems.count
    }
    
    private var purchasedCount: Int {
        cachedItems.filter { $0.purchased }.count
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
        .onAppear {
            loadCachedItems()
        }
    }
    
    private func loadCachedItems() {
        if let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)"),
           let items = try? JSONDecoder().decode([ListElement].self, from: data) {
            cachedItems = items
        } else {
            cachedItems = []
        }
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

// MARK: - Statistics Cache

struct StatisticsCache {
    let activeListCount: Int
    let totalItemsCount: Int
    let completedItemsCount: Int
    let overallCompletionRate: Double
    let listsWithItemsCount: Int
    let averageItemsPerList: Double
    
    // Default initializer for empty state
    init() {
        self.activeListCount = 0
        self.totalItemsCount = 0
        self.completedItemsCount = 0
        self.overallCompletionRate = 0
        self.listsWithItemsCount = 0
        self.averageItemsPerList = 0
    }
    
    // Custom initializer
    init(activeListCount: Int, totalItemsCount: Int, completedItemsCount: Int, overallCompletionRate: Double, listsWithItemsCount: Int, averageItemsPerList: Double) {
        self.activeListCount = activeListCount
        self.totalItemsCount = totalItemsCount
        self.completedItemsCount = completedItemsCount
        self.overallCompletionRate = overallCompletionRate
        self.listsWithItemsCount = listsWithItemsCount
        self.averageItemsPerList = averageItemsPerList
    }
    
    static func calculate(from lists: [ListItem]) -> StatisticsCache {
        var totalItems = 0
        var completedItems = 0
        var activeLists = 0
        var listsWithItems = 0
        
        for list in lists {
            if let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)"),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                
                totalItems += items.count
                completedItems += items.filter { $0.purchased }.count
                
                if !items.isEmpty {
                    activeLists += 1
                    listsWithItems += 1
                }
            }
        }
        
        let completionRate = totalItems > 0 ? Double(completedItems) / Double(totalItems) : 0
        let averageItems = lists.count > 0 ? Double(totalItems) / Double(lists.count) : 0
        
        return StatisticsCache(
            activeListCount: activeLists,
            totalItemsCount: totalItems,
            completedItemsCount: completedItems,
            overallCompletionRate: completionRate,
            listsWithItemsCount: listsWithItems,
            averageItemsPerList: averageItems
        )
    }
}

