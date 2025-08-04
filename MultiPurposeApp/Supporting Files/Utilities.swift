import Foundation
import SwiftUI

// MARK: - Data Persistence Utilities
/// Utilities for managing data persistence with UserDefaults
struct DataPersistence {
    
    // MARK: - User Management
    /// Saves user data to UserDefaults
    static func saveUser(_ user: TempUser) {
        do {
            let encoded = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encoded, forKey: "user_\(user.userId)")
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    /// Loads user data from UserDefaults
    static func loadUser(userId: String) -> TempUser? {
        guard let data = UserDefaults.standard.data(forKey: "user_\(userId)") else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(TempUser.self, from: data)
        } catch {
            print("Failed to load user: \(error)")
            return nil
        }
    }
    
    // MARK: - List Management
    /// Saves lists to UserDefaults
    static func saveLists(_ lists: [ListItem], for userId: String) {
        do {
            let encoded = try JSONEncoder().encode(lists)
            UserDefaults.standard.set(encoded, forKey: "lists_\(userId)")
        } catch {
            print("Failed to save lists: \(error)")
        }
    }
    
    /// Loads lists from UserDefaults
    static func loadLists(for userId: String) -> [ListItem] {
        guard let data = UserDefaults.standard.data(forKey: "lists_\(userId)") else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([ListItem].self, from: data)
        } catch {
            print("Failed to load lists: \(error)")
            return []
        }
    }
    
    /// Saves deleted lists to UserDefaults
    static func saveDeletedLists(_ lists: [ListItem], for userId: String) {
        do {
            let encoded = try JSONEncoder().encode(lists)
            UserDefaults.standard.set(encoded, forKey: "deletedLists_\(userId)")
        } catch {
            print("Failed to save deleted lists: \(error)")
        }
    }
    
    /// Loads deleted lists from UserDefaults
    static func loadDeletedLists(for userId: String) -> [ListItem] {
        guard let data = UserDefaults.standard.data(forKey: "deletedLists_\(userId)") else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([ListItem].self, from: data)
        } catch {
            print("Failed to load deleted lists: \(error)")
            return []
        }
    }
    
    // MARK: - Item Management
    /// Saves list items to UserDefaults
    static func saveItems(_ items: [ListElement], for listId: String) {
        do {
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: "items_\(listId)")
        } catch {
            print("Failed to save items: \(error)")
        }
    }
    
    /// Loads list items from UserDefaults
    static func loadItems(for listId: String) -> [ListElement] {
        guard let data = UserDefaults.standard.data(forKey: "items_\(listId)") else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([ListElement].self, from: data)
        } catch {
            print("Failed to load items: \(error)")
            return []
        }
    }
    
    // MARK: - Cleanup
    /// Clears all data for a specific user
    static func clearUserData(userId: String) {
        UserDefaults.standard.removeObject(forKey: "user_\(userId)")
        UserDefaults.standard.removeObject(forKey: "lists_\(userId)")
        UserDefaults.standard.removeObject(forKey: "deletedLists_\(userId)")
        
        // Clear all items for this user's lists
        let lists = loadLists(for: userId)
        for list in lists {
            UserDefaults.standard.removeObject(forKey: "items_\(list.id.uuidString)")
        }
    }
}

// MARK: - Validation Utilities
/// Utilities for input validation
struct Validation {
    
    /// Validates email format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates password strength
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    /// Validates list name
    static func isValidListName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 100
    }
    
    /// Validates item name
    static func isValidItemName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 200
    }
}

// MARK: - Date Utilities
/// Utilities for date formatting and manipulation
struct DateUtils {
    
    /// Formats a date for display
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
    
    /// Gets relative time string
    static func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// Checks if a date is today
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Checks if a date is this week
    static func isThisWeek(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Checks if a date is this month
    static func isThisMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
}

// MARK: - Performance Utilities
/// Utilities for performance optimization
struct Performance {
    
    /// Executes code on background thread and updates UI on main thread
    static func performBackgroundTask<T>(_ task: @escaping () -> T, completion: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = task()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    /// Debounces a function call
    static func debounce(delay: TimeInterval, action: @escaping () -> Void) -> () -> Void {
        var timer: Timer?
        return {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                action()
            }
        }
    }
}

// MARK: - Accessibility Utilities
/// Utilities for accessibility features
struct Accessibility {
    
    /// Creates accessibility label for list item
    static func listItemLabel(name: String, itemCount: Int, completedCount: Int) -> String {
        if itemCount == 0 {
            return "\(name), empty list"
        } else if completedCount == itemCount {
            return "\(name), \(itemCount) items, all completed"
        } else {
            return "\(name), \(itemCount) items, \(completedCount) completed"
        }
    }
    
    /// Creates accessibility hint for list item
    static func listItemHint(itemCount: Int, completedCount: Int) -> String {
        if itemCount == 0 {
            return "Double tap to add items"
        } else {
            return "Double tap to view items"
        }
    }
} 