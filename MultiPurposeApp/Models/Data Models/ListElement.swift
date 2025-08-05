import Foundation

// MARK: - List Element Model
/// Represents an individual item within a list
struct ListElement: Codable, Identifiable, Equatable {
    
    // MARK: - Properties
    var id = UUID()
    let name: String
    var purchased: Bool = false
    
    // MARK: - Initialization
    init(name: String) {
        self.name = name
        self.purchased = false
    }
    
    init(name: String, purchased: Bool) {
        self.name = name
        self.purchased = purchased
    }
    
    // MARK: - Computed Properties
    /// Returns the display name for the item
    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns whether the item is valid (has a non-empty name)
    var isValid: Bool {
        !displayName.isEmpty
    }
    
    // MARK: - Methods
    /// Toggles the purchased status of the item
    mutating func togglePurchased() {
        purchased.toggle()
    }
    
    /// Marks the item as purchased
    mutating func markAsPurchased() {
        purchased = true
    }
    
    /// Marks the item as not purchased
    mutating func markAsNotPurchased() {
        purchased = false
    }
}

// MARK: - List Item Model
/// Represents a collection of items (a list)
struct ListItem: Identifiable, Codable {
    
    // MARK: - Properties
    var id = UUID()
    let name: String
    let createdAt: Date
    
    // MARK: - Initialization
    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
    
    init(name: String, createdAt: Date) {
        self.name = name
        self.createdAt = createdAt
    }
    
    // MARK: - Computed Properties
    /// Returns the display name for the list
    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns whether the list is valid (has a non-empty name)
    var isValid: Bool {
        !displayName.isEmpty
    }
    
    /// Returns the formatted creation date
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    /// Returns the relative time since creation
    var relativeCreatedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Statistics Cache Model
/// Cached statistics for performance optimization
struct StatisticsCache {
    
    // MARK: - Properties
    var activeListCount: Int = 0
    var totalItemsCount: Int = 0
    var completedItemsCount: Int = 0
    var overallCompletionRate: Double = 0.0
    var listsWithItemsCount: Int = 0
    var averageItemsPerList: Double = 0.0
    
    // MARK: - Computed Properties
    /// Returns the percentage of completed items
    var completionPercentage: Double {
        guard totalItemsCount > 0 else { return 0.0 }
        return (Double(completedItemsCount) / Double(totalItemsCount)) * 100
    }
    
    /// Returns the number of remaining items
    var remainingItemsCount: Int {
        totalItemsCount - completedItemsCount
    }
    
    /// Returns whether there are any active lists
    var hasActiveLists: Bool {
        activeListCount > 0
    }
    
    /// Returns whether there are any items
    var hasItems: Bool {
        totalItemsCount > 0
    }
    
    // MARK: - Static Methods
    /// Calculates statistics from a list of ListItems
    static func calculate(from lists: [ListItem]) -> StatisticsCache {
        var stats = StatisticsCache()
        
        for list in lists {
            if let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)"),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                
                stats.totalItemsCount += items.count
                stats.completedItemsCount += items.filter { $0.purchased }.count
                
                if !items.isEmpty {
                    stats.activeListCount += 1
                    stats.listsWithItemsCount += 1
                }
            }
        }
        
        stats.overallCompletionRate = stats.totalItemsCount > 0 ? 
            Double(stats.completedItemsCount) / Double(stats.totalItemsCount) : 0.0
        
        stats.averageItemsPerList = lists.count > 0 ? 
            Double(stats.totalItemsCount) / Double(lists.count) : 0.0
        
        return stats
    }
}

// MARK: - User Model
/// Represents a user of the application
struct TempUser: Codable {
    
    // MARK: - Properties
    let firstName: String
    let lastName: String
    let userId: String // Email address
    let password: String
    
    // MARK: - Computed Properties
    /// Returns the full name of the user
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Returns the display name (first name only)
    var displayName: String {
        firstName
    }
    
    /// Returns whether the user is valid
    var isValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !userId.isEmpty && !password.isEmpty
    }
    
    // MARK: - Static Properties
    /// Default test users for development
    static let `default` = TempUser(
        firstName: "Varun",
        lastName: "Patel",
        userId: "vickypatel.13@gmail.com",
        password: "Gmail1984"
    )
    
    /// Additional default user for testing
    static let `user` = TempUser(
        firstName: "TempUser",
        lastName: "Temp",
        userId: "user@example.com",
        password: "Pass@1984"
    )
} 