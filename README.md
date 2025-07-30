# MultiPurposeApp - MVP Version 1.0

A modern, feature-rich iOS list management application built with SwiftUI and SwiftData. This app provides users with a comprehensive solution for creating, managing, and tracking various types of lists with beautiful iOS-native design and robust functionality.

## 📱 App Overview

MultiPurposeApp is designed to help users organize their tasks, shopping lists, and other items with an intuitive interface, secure authentication, and powerful statistics tracking. The app features a modern glassmorphism design with smooth animations and a comprehensive set of features for list management.

## ✨ Key Features

### 🔐 Authentication System
- **Secure Login/Signup** with email and password validation
- **Session Persistence** - users stay logged in between app launches
- **Default Test User** (`user@example.com` / `Password123`)
- **Password Visibility Toggle** for enhanced user experience
- **Input Validation** with real-time feedback
- **Animated Loading Screen** during authentication

### 📋 List Management
- **Create Multiple Lists** with custom names and timestamps
- **Add/Remove Items** with real-time updates
- **Mark Items as Completed** with visual feedback
- **Swipe Actions** for quick list and item management
- **Alphabetical Sorting** of items within lists
- **Progress Tracking** with completion percentages

### 🗑️ Deleted Lists Management
- **Soft Delete** - lists move to Deleted tab instead of permanent removal
- **Restore Functionality** - easily restore deleted lists
- **Permanent Delete** - option to permanently remove lists and items
- **Swipe Actions** for restore and permanent delete operations

### 📊 Comprehensive Statistics
- **Overview Metrics**: Total lists, active lists, total items, completed items
- **Progress Tracking**: Overall completion rates and list utilization
- **Activity Analytics**: Weekly/monthly list creation trends
- **Recent Activity**: Most recent list details and performance
- **Visual Progress Bars** and color-coded statistics

### 🎨 Modern UI/UX
- **iOS-Native Design** with system colors and typography
- **Glassmorphism Effects** with gradient backgrounds
- **Smooth Animations** and transitions
- **Tab-Based Navigation** with 4 main sections
- **Responsive Layout** that adapts to different screen sizes
- **Accessibility Support** with proper focus management

## 🏗️ Technical Architecture

### **Technology Stack**
- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Core Data replacement for data persistence
- **UserDefaults** - Lightweight data storage for user preferences
- **Foundation** - Core iOS framework for data handling

### **Data Models**

#### `TempUser`
```swift
struct TempUser: Codable {
    let firstName: String
    let lastName: String
    let userId: String // Email address
    let password: String
}
```

#### `ListItem`
```swift
struct ListItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let createdAt: Date
}
```

#### `ListElement`
```swift
struct ListElement: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var purchased: Bool
}
```

### **Core Views**

#### `ContentView`
- Main entry point with authentication flow
- Handles login/signup with validation
- Manages user session persistence
- Features animated loading screen

#### `HomePage`
- Main dashboard with tab navigation
- List management and creation
- Statistics overview
- User profile management

#### `ListItemsView`
- Individual list item management
- Add/remove items functionality
- Progress tracking and completion
- Alphabetical sorting

#### `LoggingInView`
- Animated loading screen during authentication
- Walking figure animation with progress indicator

## 📱 User Interface

### **Tab Navigation**
1. **Lists Tab** - Main list management interface
2. **Deleted Tab** - Soft-deleted lists with restore options
3. **Stats Tab** - Comprehensive statistics and analytics
4. **Profile Tab** - User information and logout

### **Design System**
- **Color Palette**: Blue, Purple, Green, Orange, Red themes
- **Typography**: System fonts with proper hierarchy
- **Spacing**: Consistent 8pt grid system
- **Corner Radius**: 12pt for cards, 22pt for buttons
- **Shadows**: Subtle depth with opacity variations

## 🔧 Installation & Setup

### **Prerequisites**
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS 14.0 or later (for development)

### **Installation Steps**
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/MultiPurposeApp.git
   ```

2. Open the project in Xcode:
   ```bash
   cd MultiPurposeApp
   open MultiPurposeApp.xcodeproj
   ```

3. Build and run the project:
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### **Default Test Account**
- **Email**: `user@example.com`
- **Password**: `Password123`

## 🚀 Usage Guide

### **Getting Started**
1. Launch the app
2. Tap "Get Started" on the welcome screen
3. Use the default account or create a new one
4. Start creating your first list

### **Creating Lists**
1. Navigate to the Lists tab
2. Tap the "+" button in the bottom right
3. Enter a list name
4. Tap "Create List"

### **Managing Items**
1. Tap on any list to open it
2. Use the text field to add new items
3. Tap items to mark them as completed
4. Swipe left on items to delete them

### **Deleting Lists**
1. Swipe right on any list in the Lists tab
2. Tap "Delete" to move to Deleted tab
3. Lists can be restored from the Deleted tab

### **Viewing Statistics**
1. Navigate to the Stats tab
2. View comprehensive analytics about your lists
3. Track progress and activity over time

## 📊 Data Persistence

### **Storage Strategy**
- **UserDefaults**: Primary storage for user data, lists, and items
- **JSON Encoding**: Data serialization for complex objects
- **User-Specific Keys**: Each user's data is isolated
- **Automatic Saving**: Data persists across app launches

### **Data Structure**
```
UserDefaults Keys:
- "registeredUsers" - All registered users
- "loggedInUser" - Currently logged in user
- "lists_{userId}" - User's lists
- "deletedLists_{userId}" - User's deleted lists
- "items_{listId}" - Items for specific list
```

## 🔒 Security & Privacy

### **Authentication**
- Local authentication with email/password
- Session persistence with secure storage
- Input validation and sanitization
- Password visibility controls

### **Data Privacy**
- User data is stored locally on device
- No external data transmission
- User-specific data isolation
- Secure data encoding/decoding

## 🧪 Testing

### **Test Scenarios**
- User registration and login
- List creation and management
- Item addition and completion
- List deletion and restoration
- Statistics calculation accuracy
- Data persistence across app restarts

### **Test Data**
The app includes a default test user for immediate testing:
- Email: `user@example.com`
- Password: `Password123`

## 📈 Performance

### **Optimizations**
- Lazy loading for large lists
- Efficient data processing with computed properties
- Minimal memory footprint
- Smooth animations with proper timing

### **Scalability**
- Efficient data structures
- User-specific data isolation
- Modular component architecture
- Extensible design patterns

## 🔮 Future Enhancements

### **Planned Features**
- Cloud synchronization
- List sharing and collaboration
- Advanced filtering and search
- Custom categories and tags
- Export and backup functionality
- Dark mode support
- Widget support

### **Technical Improvements**
- Core Data integration
- Push notifications
- Advanced analytics
- Performance optimizations
- Accessibility enhancements

## 🤝 Contributing

### **Development Guidelines**
- Follow SwiftUI best practices
- Maintain consistent coding style
- Add proper documentation
- Test thoroughly before submitting
- Use meaningful commit messages

### **Code Style**
- Use SwiftUI declarative syntax
- Follow Apple's Human Interface Guidelines
- Implement proper error handling
- Use meaningful variable and function names

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Varun Patel**
- Created: July 28, 2025
- Version: 1.0.0
- Platform: iOS

## 📞 Support

For support, questions, or feature requests:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation for common solutions

---

**MultiPurposeApp v1.0** - A modern iOS list management solution built with love and SwiftUI. 