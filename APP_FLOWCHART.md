# MultiPurposeApp - User Flow Chart

**Last Updated**: July 31, 2025  
**Version**: 1.0.0 (MVP)

## Overview

This document provides a comprehensive flowchart of all possible user flows in the MultiPurposeApp, from initial launch to all possible user interactions and navigation paths.

## Main Application Flow

```mermaid
flowchart TD
    A[App Launch] --> B{User Logged In?}
    B -->|No| C[ContentView - Welcome Screen]
    B -->|Yes| D[HomePage - Main Dashboard]
    
    C --> E[Get Started Button]
    E --> F[Authentication Sheet]
    F --> G{Login or Sign Up?}
    
    G -->|Login| H[Login Form]
    G -->|Sign Up| I[Sign Up Form]
    
    H --> J{Valid Credentials?}
    I --> K{Valid Registration?}
    
    J -->|No| L[Show Error Alert]
    J -->|Yes| M[LoggingInView - Loading Screen]
    K -->|No| N[Show Validation Error]
    K -->|Yes| O[Create New User]
    
    L --> H
    N --> I
    O --> M
    
    M --> D
```

## Authentication Flow

```mermaid
flowchart TD
    A[Authentication Sheet] --> B{Mode Selection}
    B -->|Login| C[Login Mode]
    B -->|Sign Up| D[Sign Up Mode]
    
    C --> E[Email Field]
    E --> F[Password Field]
    F --> G[Show/Hide Password Toggle]
    G --> H[Login Button]
    
    D --> I[First Name Field]
    I --> J[Last Name Field]
    J --> K[Email Field]
    K --> L[Password Field]
    L --> M[Confirm Password Field]
    M --> N[Show/Hide Password Toggle]
    N --> O[Sign Up Button]
    
    H --> P{Validate Login}
    O --> Q{Validate Registration}
    
    P -->|Invalid| R[Show Error Alert]
    P -->|Valid| S[Start Loading Screen]
    Q -->|Invalid| T[Show Validation Error]
    Q -->|Valid| U[Create User & Start Loading]
    
    R --> C
    T --> D
    S --> V[LoggingInView - 8 Second Animation]
    U --> V
    V --> W[HomePage]
```

## Main Dashboard Navigation

```mermaid
flowchart TD
    A[HomePage] --> B[TabView Navigation]
    B --> C[Lists Tab - Index 0]
    B --> D[Deleted Tab - Index 1]
    B --> E[Stats Tab - Index 2]
    B --> F[Profile Tab - Index 3]
    
    C --> G[ListsView]
    D --> H[DeletedView]
    E --> I[StatsView]
    F --> J[ProfileView]
    
    G --> K{List Actions}
    H --> L{Deleted List Actions}
    I --> M[View Statistics]
    J --> N{Profile Actions}
```

## Lists Management Flow

```mermaid
flowchart TD
    A[ListsView] --> B{List Count}
    B -->|0 Lists| C[Empty State View]
    B -->|>0 Lists| D[Lists List]
    
    C --> E[Create First List Button]
    E --> F[Add List Sheet]
    
    D --> G[Floating Action Button +]
    G --> F
    
    F --> H[Enter List Name]
    H --> I{Valid Name?}
    I -->|No| J[Disable Create Button]
    I -->|Yes| K[Enable Create Button]
    
    J --> H
    K --> L[Create List Button]
    L --> M[Save to UserDefaults]
    M --> N[Close Sheet]
    N --> O[Refresh Lists]
    
    D --> P[Tap on List]
    P --> Q[ListItemsView - Full Screen]
    
    D --> R[Swipe Left on List]
    R --> S[Delete Action]
    S --> T[Delete Confirmation Alert]
    T --> U{Confirm Delete?}
    U -->|No| V[Cancel Delete]
    U -->|Yes| W[Move to Deleted Lists]
    
    V --> D
    W --> X[Remove from Active Lists]
    X --> Y[Add to Deleted Lists]
    Y --> Z[Refresh Lists]
```

## List Items Management Flow

```mermaid
flowchart TD
    A[ListItemsView] --> B[List Header Info]
    B --> C[List Name & Date]
    C --> D[Progress Bar]
    D --> E[Total Items / Purchased Count]
    E --> F[Completion Percentage]
    
    F --> G[Add Item Input Field]
    G --> H{Valid Item Name?}
    H -->|No| I[Disable Add Button]
    H -->|Yes| J[Enable Add Button]
    
    I --> G
    J --> K[Add Item Button]
    K --> L[Create ListElement]
    L --> M[Save to UserDefaults]
    M --> N[Clear Input Field]
    N --> O[Refresh Items List]
    
    O --> P[Items List - Sorted Alphabetically]
    P --> Q[Tap Item Checkbox]
    Q --> R[Toggle Purchased Status]
    R --> S[Update Progress Bar]
    S --> T[Save to UserDefaults]
    
    P --> U[Swipe Left on Item]
    U --> V[Delete Item Action]
    V --> W[Remove from Items Array]
    W --> X[Save to UserDefaults]
    X --> Y[Refresh Items List]
    
    A --> Z[Back Button]
    Z --> AA[Return to ListsView]
    AA --> BB[Refresh Lists Data]
```

## Deleted Lists Management Flow

```mermaid
flowchart TD
    A[DeletedView] --> B{Deleted Lists Count}
    B -->|0 Lists| C[Empty Deleted State]
    B -->|>0 Lists| D[Deleted Lists List]
    
    C --> E[Message: No deleted lists]
    E --> F[Return to Lists Tab]
    
    D --> G[Tap on Deleted List]
    G --> H[View List Details]
    
    D --> I[Swipe Left on Deleted List]
    I --> J[Restore Action]
    I --> K[Delete Forever Action]
    
    J --> L[Restore Confirmation Alert]
    L --> M{Confirm Restore?}
    M -->|No| N[Cancel Restore]
    M -->|Yes| O[Move Back to Active Lists]
    
    N --> D
    O --> P[Remove from Deleted Lists]
    P --> Q[Add to Active Lists]
    Q --> R[Refresh Both Lists]
    
    K --> S[Delete Forever Confirmation Alert]
    S --> T{Confirm Permanent Delete?}
    T -->|No| U[Cancel Delete]
    T -->|Yes| V[Permanently Remove from Deleted Lists]
    
    U --> D
    V --> W[Remove from UserDefaults]
    W --> X[Refresh Deleted Lists]
```

## Statistics Dashboard Flow

```mermaid
flowchart TD
    A[StatsView] --> B[Statistics Cards]
    B --> C[Active Lists Count]
    B --> D[Total Items Count]
    B --> E[Completed Items Count]
    B --> F[Overall Completion Rate]
    B --> G[Lists with Items Count]
    B --> H[Average Items per List]
    
    A --> I[Activity Tracking]
    I --> J[Most Recent List]
    I --> K[Lists Created This Week]
    I --> L[Lists Created This Month]
    
    A --> M[Deleted Lists Summary]
    M --> N[Deleted Lists Count]
    N --> O[View Deleted Lists Button]
    O --> P[Navigate to Deleted Tab]
    
    A --> Q[Performance Optimizations]
    Q --> R[Background Statistics Calculation]
    R --> S[Cached Statistics Display]
    S --> T[Real-time Updates]
```

## Profile Management Flow

```mermaid
flowchart TD
    A[ProfileView] --> B[User Information Display]
    B --> C[User Avatar]
    C --> D[User Name]
    D --> E[User Details Card]
    E --> F[First Name]
    E --> G[Last Name]
    E --> H[User ID/Email]
    
    A --> I[Data Backup Section]
    I --> J[GitHub Sync Button]
    I --> K[iCloud Sync Button]
    
    J --> L[GitHubSyncView Sheet]
    K --> M[iCloudSyncView Sheet]
    
    A --> N[Logout Button]
    N --> O[Logout Confirmation]
    O --> P{Confirm Logout?}
    P -->|No| Q[Cancel Logout]
    P -->|Yes| R[Clear User Session]
    
    Q --> A
    R --> S[Return to ContentView]
```

## GitHub Sync Flow

```mermaid
flowchart TD
    A[GitHubSyncView] --> B{Authentication Status}
    B -->|Not Authenticated| C[Authentication Section]
    B -->|Authenticated| D[Connected State]
    
    C --> E[Access Token Input]
    E --> F[Connect to GitHub Button]
    F --> G[Authenticate with Token]
    G --> H{Authentication Success?}
    H -->|No| I[Show Error Alert]
    H -->|Yes| J[Update Authentication Status]
    
    I --> C
    J --> D
    
    D --> K[Backup Section]
    D --> L[Restore Section]
    
    K --> M[Backup Data Button]
    M --> N[Create BackupData Object]
    N --> O[Encode to JSON]
    O --> P[Create/Update GitHub Gist]
    P --> Q{Backup Success?}
    Q -->|No| R[Show Error Alert]
    Q -->|Yes| S[Update Last Sync Date]
    
    R --> K
    S --> T[Show Success Message]
    
    L --> U[Restore Data Button]
    U --> V[Fetch GitHub Gist]
    V --> W{Data Found?}
    W -->|No| X[Show No Data Alert]
    W -->|Yes| Y[Decode BackupData]
    Y --> Z{Decode Success?}
    Z -->|No| AA[Show Error Alert]
    Z -->|Yes| BB[Confirm Restore Alert]
    
    X --> L
    AA --> L
    BB --> CC{Confirm Restore?}
    CC -->|No| DD[Cancel Restore]
    CC -->|Yes| EE[Restore Data to App]
    
    DD --> L
    EE --> FF[Update App Data]
    FF --> GG[Show Success Message]
    GG --> HH[Close Sync View]
```

## iCloud Sync Flow

```mermaid
flowchart TD
    A[iCloudSyncView] --> B{iCloud Available?}
    B -->|No| C[iCloud Not Available State]
    B -->|Yes| D[iCloud Available State]
    
    C --> E[Warning Message]
    E --> F[Open Settings Button]
    F --> G[Open System Settings]
    
    D --> H[Status Information]
    H --> I[Last Sync Date]
    I --> J[Check Status Button]
    J --> K[Verify iCloud Status]
    
    D --> L[Manual Sync Section]
    L --> M[Backup to iCloud Button]
    L --> N[Restore from iCloud Button]
    
    M --> O[Encode App Data]
    O --> P[Save to iCloud KVS]
    P --> Q{Sync Success?}
    Q -->|No| R[Show Error Alert]
    Q -->|Yes| S[Update Last Sync Date]
    
    R --> L
    S --> T[Show Success Message]
    
    N --> U[Load from iCloud KVS]
    U --> V{Data Found?}
    V -->|No| W[Show No Data Alert]
    V -->|Yes| X[Decode App Data]
    X --> Y{Decode Success?}
    Y -->|No| Z[Show Error Alert]
    Y -->|Yes| AA[Confirm Restore Alert]
    
    W --> L
    Z --> L
    AA --> BB{Confirm Restore?}
    BB -->|No| CC[Cancel Restore]
    BB -->|Yes| DD[Restore Data to App]
    
    CC --> L
    DD --> EE[Update App Data]
    EE --> FF[Show Success Message]
    FF --> GG[Close Sync View]
```

## Error Handling Flow

```mermaid
flowchart TD
    A[Error Occurs] --> B{Error Type}
    B -->|Validation Error| C[Show Input Validation Alert]
    B -->|Network Error| D[Show Network Error Alert]
    B -->|Authentication Error| E[Show Auth Error Alert]
    B -->|Data Error| F[Show Data Error Alert]
    B -->|Sync Error| G[Show Sync Error Alert]
    
    C --> H[Return to Input Form]
    D --> I[Retry Network Operation]
    E --> J[Return to Auth Screen]
    F --> K[Return to Previous Screen]
    G --> L[Return to Sync Screen]
    
    H --> M[User Corrects Input]
    I --> N[Retry Request]
    J --> O[User Re-enters Credentials]
    K --> P[User Takes Corrective Action]
    L --> Q[User Retries Sync]
```

## Data Persistence Flow

```mermaid
flowchart TD
    A[Data Change Event] --> B{Change Type}
    B -->|User Data| C[Save to UserDefaults]
    B -->|List Data| D[Save to UserDefaults]
    B -->|Item Data| E[Save to UserDefaults]
    B -->|Sync Data| F[Save to Cloud]
    
    C --> G[Update registeredUsers Key]
    D --> H[Update lists_{userId} Key]
    E --> I[Update items_{listId} Key]
    F --> J[GitHub Gist or iCloud KVS]
    
    G --> K[Data Persisted Locally]
    H --> K
    I --> K
    J --> L[Data Persisted to Cloud]
    
    K --> M[Trigger UI Update]
    L --> N[Trigger Sync Status Update]
    
    M --> O[Refresh Related Views]
    N --> P[Update Last Sync Date]
```

## Performance Optimization Flow

```mermaid
flowchart TD
    A[Statistics Request] --> B{Statistics Cached?}
    B -->|Yes| C[Return Cached Statistics]
    B -->|No| D[Start Background Calculation]
    
    D --> E[Move to Background Thread]
    E --> F[Calculate Statistics]
    F --> G[Update Cache]
    G --> H[Return to Main Thread]
    H --> I[Update UI]
    
    C --> I
    
    A --> J[List Item Request]
    J --> K{Items Cached?}
    K -->|Yes| L[Return Cached Items]
    K -->|No| M[Load from UserDefaults]
    
    M --> N[Decode JSON Data]
    N --> O[Cache Items]
    O --> L
    
    L --> P[Display Items]
```

## Complete User Journey Examples

### New User Journey
```mermaid
flowchart TD
    A[App Launch] --> B[Welcome Screen]
    B --> C[Get Started]
    C --> D[Sign Up Form]
    D --> E[Enter User Details]
    E --> F[Create Account]
    F --> G[Loading Screen]
    G --> H[Main Dashboard]
    H --> I[Create First List]
    I --> J[Add Items]
    J --> K[Use App Features]
```

### Returning User Journey
```mermaid
flowchart TD
    A[App Launch] --> B[Auto Login]
    B --> C[Main Dashboard]
    C --> D[View Existing Lists]
    D --> E[Manage Lists & Items]
    E --> F[View Statistics]
    F --> G[Use Sync Features]
    G --> H[Logout]
```

### Data Backup Journey
```mermaid
flowchart TD
    A[Profile Tab] --> B[Data Backup Section]
    B --> C[Choose Sync Method]
    C --> D{GitHub or iCloud?}
    D -->|GitHub| E[GitHub Sync View]
    D -->|iCloud| F[iCloud Sync View]
    
    E --> G[Enter Access Token]
    G --> H[Authenticate]
    H --> I[Backup Data]
    I --> J[Confirm Success]
    
    F --> K[Check iCloud Status]
    K --> L[Backup Data]
    L --> M[Confirm Success]
```

---

**MultiPurposeApp v1.0.0** - Comprehensive user flow documentation for all possible navigation paths and interactions.  
*Last Updated: July 31, 2025* 