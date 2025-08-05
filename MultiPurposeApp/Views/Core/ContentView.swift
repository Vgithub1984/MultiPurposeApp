//
//  ContentView.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//
//  This file defines the main ContentView for the MultiPurposeApp,
//  including the landing page, authentication flow (login/sign up),
//  session management, and navigation to the home page upon successful login.
//

import SwiftUI
import SwiftData
import Foundation
// Removed import TempUser as per instructions

/// Extension to conform TempUser to Identifiable for use in SwiftUI views.
extension TempUser: Identifiable {
    /// Unique identifier for TempUser, based on userId (email).
    var id: String { userId }
}

/// A custom button style that mimics a liquid glass effect.
/// Applies shadows, gradients, blur and scale animation on press.
struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .blur(radius: configuration.isPressed ? 4 : 1)
                        .shadow(color: Color.appShadow, radius: 14, x: 0, y: 4)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            ColorTheme.glassGradient,
                            lineWidth: 2
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimaryText.opacity(configuration.isPressed ? 0.06 : 0.13), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// The main content view of the app, responsible for displaying the welcome screen,
/// managing user authentication (login/sign up), session persistence,
/// and navigation to the HomePage on successful login.
struct ContentView: View {
    
    // MARK: - Authentication State Properties
    
    /// Controls whether to show the authentication sheet (login/signup).
    @State private var showAuthSheet: Bool = false
    
    /// Tracks whether user is in login mode (true) or sign up mode (false).
    @State private var isLogin: Bool = true
    
    /// Email input field state.
    @State private var email: String = ""
    
    /// Password input field state.
    @State private var password: String = ""
    
    /// Controls the display of alert messages.
    @State private var showAlert: Bool = false
    
    /// Holds the current alert message to be displayed.
    @State private var alertMessage: String = ""
    
    /// Toggles visibility of the password field.
    @State private var showPassword: Bool = false
    
    /// First name input field state for sign up.
    @State private var firstName: String = ""
    
    /// Last name input field state for sign up.
    @State private var lastName: String = ""
    
    /// Confirm password input field state for sign up.
    @State private var confirmPassword: String = ""
    
    /// Toggles visibility of the confirm password field.
    @State private var showConfirmPassword: Bool = false
    
    /// Stores all registered users, initialized with default user if none saved.
    @State private var registeredUsers: [TempUser] = []
    
    /// Holds the currently logged-in user to present the HomePage.
    @State private var loggedInUser: TempUser? = nil
    
    /// Enum for managing focus between authentication form fields.
    enum AuthField: Hashable {
        case firstName, lastName, email, password, confirmPassword
    }
    
    /// Focus state for controlling keyboard focus on authentication fields.
    @FocusState private var focusedField: AuthField?
    
    var body: some View {
        
        ZStack {
            // Background gradient for entire screen
            ColorTheme.primaryGradient
                .ignoresSafeArea(.all)
            
            VStack {
                // MARK: - Header: App Icon and Title
                
                Image(systemName: "list.bullet.clipboard.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        Color.appPrimary,
                        Color.appSecondary.opacity(0.7),
                        Color.appPrimaryText.opacity(0.8)
                    )
                    .font(.system(size: 150))
                
                Text("")
                Text("MultiPurposeApp")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.appPrimaryText)
                
                Spacer()
                
                // MARK: - Features List
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.appPrimaryText)
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color.appSuccess)
                        Text("Secure and Reliable")
                            .foregroundColor(Color.appPrimaryText)
                    }
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.appInfo)
                        Text("Highly Customizable")
                            .foregroundColor(Color.appPrimaryText)
                    }
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color.appWarning)
                        Text("Fast Performance")
                            .foregroundColor(Color.appPrimaryText)
                    }
                }
                
                Spacer()
                
                // MARK: - Get Started Button
                
                Button("Get Started") {
                    // On tap, show authentication sheet to allow login or sign up
                    showAuthSheet = true
                }
                .buttonStyle(LiquidGlassButtonStyle())
                
            }
            .padding(.top, 30)
            
            // MARK: - Authentication Sheet (Login / Sign Up)
            
            .sheet(isPresented: $showAuthSheet) {
                NavigationView {
                    VStack(spacing: 20) {
                        // Picker to toggle between Login and Sign Up modes
                        Picker("", selection: $isLogin) {
                            Text("Login").tag(true)
                            Text("Sign Up").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Sign Up-specific fields: First Name and Last Name
                        if !isLogin {
                            // First Name TextField with autocapitalization and focus
                            TextField("First Name", text: $firstName)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .focused($focusedField, equals: .firstName)
                            
                            // Last Name TextField, no explicit focus set here
                            TextField("Last Name", text: $lastName)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        // Email field for both login and sign up, focused accordingly
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .focused($focusedField, equals: .email)
                        
                        // Password input with toggleable visibility (secure or plain)
                        ZStack {
                            if showPassword {
                                // Show password as plain text when visible
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .padding(.trailing, 40) // Space for visibility toggle button
                            } else {
                                // SecureField masks the password characters
                                SecureField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .padding(.trailing, 40) // Space for visibility toggle button
                            }
                            
                            // Button to toggle password visibility, aligned trailing
                            HStack {
                                Spacer()
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(Color.appSecondaryText)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                        
                        // Confirm Password field, only shown during Sign Up
                        if !isLogin {
                            ZStack {
                                if showConfirmPassword {
                                    // Plain text confirm password field
                                    TextField("Confirm Password", text: $confirmPassword)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                        .padding(.trailing, 40)
                                } else {
                                    // Secure confirm password field
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                        .padding(.trailing, 40)
                                }
                                
                                // Toggle visibility button for confirm password
                                HStack {
                                    Spacer()
                                    Button {
                                        showConfirmPassword.toggle()
                                    } label: {
                                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                            .foregroundColor(Color.appSecondaryText)
                                    }
                                    .padding(.trailing, 10)
                                }
                            }
                        }
                        
                        // "Forgot Password?" button shown only in login mode
                        if isLogin {
                            Button("Forgot Password?") {
                                // Inform user about password reset instructions via alert
                                alertMessage = "Password reset instructions would be sent to your email."
                                showAlert = true
                            }
                            .font(.footnote)
                            .foregroundColor(Color.appPrimary)
                            .padding(.top, -8)
                        }
                        
                        // MARK: - Primary Action Button for Login or Sign Up
                        
                        Button(isLogin ? "Login" : "Sign Up") {
                            // Validate required fields for both login and sign up
                            if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                alertMessage = "Please fill in all fields."
                                showAlert = true
                                return
                            }
                            // Basic email format check
                            if !email.contains("@") || !email.contains(".") {
                                alertMessage = "Please enter a valid email address."
                                showAlert = true
                                return
                            }
                            
                            // Additional validation for Sign Up mode
                            if !isLogin {
                                // Ensure first and last names are provided
                                if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                    lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    alertMessage = "Please enter your first and last name."
                                    showAlert = true
                                    return
                                }
                                
                                // Confirm password must match password
                                if confirmPassword != password {
                                    alertMessage = "Passwords do not match."
                                    showAlert = true
                                    return
                                }
                            }
                            
                            // MARK: - Login Authentication Check
                            
                            if isLogin {
                                // Look for a matching user with correct credentials
                                if let matchedUser = registeredUsers.first(where: { $0.userId == email && $0.password == password }) {
                                    // Credentials correct - proceed with login
                                    showAuthSheet = false
                                    
                                    // Reset input fields for next use
                                    email = ""
                                    password = ""
                                    showPassword = false
                                    
                                    // Persist user list changes if any
                                    saveUsers()
                                    
                                    // Clear the logout flag since user is logging in
                                    UserDefaults.standard.removeObject(forKey: "userLoggedOut")
                                    
                                    // Save logged in user for session persistence
                                    saveLoggedInUser(matchedUser)
                                    
                                    // Immediately transition to HomePage
                                    loggedInUser = matchedUser
                                } else {
                                    // No matching user found or password incorrect
                                    alertMessage = "Incorrect email or password."
                                    showAlert = true
                                    return
                                }
                            } else {
                                // MARK: - Sign Up: Append new user
                                
                                let newUser = TempUser(firstName: firstName, lastName: lastName, userId: email, password: password)
                                registeredUsers.append(newUser)
                                
                                // Save updated users list to persistent storage
                                saveUsers()
                                
                                // Clear the logout flag since user is signing up
                                UserDefaults.standard.removeObject(forKey: "userLoggedOut")
                                
                                // Save the new user as logged in for session persistence
                                saveLoggedInUser(newUser)
                                
                                // Dismiss sign up sheet on success
                                showAuthSheet = false
                                
                                // Reset fields for next use
                                email = ""
                                password = ""
                                showPassword = false
                                firstName = ""
                                lastName = ""
                                confirmPassword = ""
                                showConfirmPassword = false
                                
                                // Automatically log in the new user
                                loggedInUser = newUser
                            }
                        }
                        .buttonStyle(LiquidGlassButtonStyle())
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    .navigationTitle(isLogin ? "Login" : "Sign Up")
                    .toolbar {
                        // Cancel button to dismiss authentication sheet and reset fields
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAuthSheet = false
                                email = ""
                                password = ""
                                showPassword = false
                                firstName = ""
                                lastName = ""
                                confirmPassword = ""
                                showConfirmPassword = false
                            }
                        }
                    }
                    // Alert shown for invalid input or info messages
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Invalid Input"),
                              message: Text(alertMessage),
                              dismissButton: .default(Text("OK")))
                    }
                }
                .onAppear {
                    // Set initial keyboard focus depending on mode
                    DispatchQueue.main.async {
                        focusedField = isLogin ? .email : .firstName
                    }
                }
                .onChange(of: isLogin) { _, newValue in
                    // Update focus on mode switch
                    DispatchQueue.main.async {
                        focusedField = newValue ? .email : .firstName
                    }
                }
            }
        }
        .onAppear {
            // Load registered users from persistent storage or default user if none saved
            registeredUsers = loadUsers()
            
            // Check if user has explicitly logged out
            let hasUserLoggedOut = UserDefaults.standard.bool(forKey: "userLoggedOut")
            
            // Only restore session if user hasn't explicitly logged out
            if !hasUserLoggedOut, let savedUser = loadLoggedInUser() {
                loggedInUser = savedUser
            }
        }
        // Full screen cover presenting HomePage when loggedInUser is set
        .fullScreenCover(item: $loggedInUser, onDismiss: {
            // When home page is dismissed, clear logged in user to return to welcome screen
            loggedInUser = nil
        }) { user in
            HomePage(user: user, onLogout: {
                // Logout handler clears session and returns to welcome screen
                logout()
            })
        }
        
    // end of var body: some view
    }
    
    // MARK: - Helper functions for saving/loading users
    
    /// Loads the list of registered users from UserDefaults.
    /// Returns default user if none are found or decoding fails.
    private func loadUsers() -> [TempUser] {
        guard let data = UserDefaults.standard.data(forKey: "registeredUsers") else {
            // If no saved users, return default user and save it
            let defaultUsers = [TempUser.default]
            saveUsers(defaultUsers)
            return defaultUsers
        }
        
        do {
            let decoded = try JSONDecoder().decode([TempUser].self, from: data)
            return decoded.isEmpty ? [TempUser.default] : decoded
        } catch {
            // Decoding error returns default user
            return [TempUser.default]
        }
    }
    
    /// Saves the current registeredUsers array to UserDefaults.
    /// Silent failure on encoding errors.
    private func saveUsers(_ users: [TempUser]? = nil) {
        let usersToSave = users ?? registeredUsers
        do {
            let encoded = try JSONEncoder().encode(usersToSave)
            UserDefaults.standard.set(encoded, forKey: "registeredUsers")
        } catch {
            // Encoding error ignored here
        }
    }
    
    // MARK: - Session Management
    
    /// Saves the currently logged in user for session persistence.
    /// - Parameter user: The TempUser instance to save.
    private func saveLoggedInUser(_ user: TempUser) {
        do {
            let encoded = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encoded, forKey: "loggedInUser")
        } catch {
            print("Failed to save logged in user: \(error)")
        }
    }
    
    /// Loads the saved logged in user from UserDefaults.
    /// Returns nil if no user is saved or decoding fails.
    private func loadLoggedInUser() -> TempUser? {
        guard let data = UserDefaults.standard.data(forKey: "loggedInUser") else {
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(TempUser.self, from: data)
            return decoded
        } catch {
            print("Failed to load logged in user: \(error)")
            return nil
        }
    }
    
    /// Logs out the current user by removing saved session data.
    /// Resets loggedInUser state to nil, which dismisses HomePage.
    private func logout() {
        // Clear the logged in user session
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        // Set a flag to indicate user has explicitly logged out
        UserDefaults.standard.set(true, forKey: "userLoggedOut")
        loggedInUser = nil
    }
    
// end of ContentView view. Ending point
}


#Preview {
    ContentView()
        
}

