//
//  ContentView.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//

import SwiftUI
import SwiftData
import Foundation
// Removed import TempUser as per instructions

extension TempUser: Identifiable {
    var id: String { userId }
}

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
                        .shadow(color: Color.blue.opacity(0.2), radius: 14, x: 0, y: 4)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.7), Color.blue.opacity(0.5), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(configuration.isPressed ? 0.06 : 0.13), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ContentView: View {
    
    // MARK: - Authentication State Properties
    @State private var showAuthSheet: Bool = false
    @State private var isLogin: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // New state property to toggle password visibility
    @State private var showPassword: Bool = false
    
    // New state properties for Sign Up fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var confirmPassword: String = ""
    @State private var showConfirmPassword: Bool = false
    
    // New state property for storing all registered users including the default user
    @State private var registeredUsers: [TempUser] = []
    
    // New state property to hold the logged in user for presenting HomePage
    @State private var loggedInUser: TempUser? = nil
    
    // Added state property to indicate logging in loading screen
    @State private var isLoggingIn: Bool = false
    
    // Add this enum and property at the top of ContentView
    enum AuthField: Hashable {
        case firstName, lastName, email, password, confirmPassword
    }
    @FocusState private var focusedField: AuthField?
    
    var body: some View {
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.5),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all) // This makes it truly full screen
            
            VStack {
                
                Image(systemName: "list.bullet.clipboard.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .blue,
                        .purple.opacity(0.7),
                        .white.opacity(0.8)
                    )
                    .font(.system(size: 150))
                
                Text("")
                Text("MultiPurposeApp")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features")
                        .font(.title2)
                        .bold()
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Secure and Reliable")
                    }
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Highly Customizable")
                    }
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Fast Performance")
                    }
                }
                
                Spacer()
                
                Button("Get Started") {
                    // Show authentication sheet when button tapped
                    showAuthSheet = true
                }
                .buttonStyle(LiquidGlassButtonStyle())
                
            }
            .padding(.top, 30)
            // Authentication Sheet
            .sheet(isPresented: $showAuthSheet) {
                NavigationView {
                    VStack(spacing: 20) {
                        // Picker to switch between Login and Signup
                        Picker("", selection: $isLogin) {
                            Text("Login").tag(true)
                            Text("Sign Up").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Sign Up fields: First Name and Last Name
                        if !isLogin {
                            // First Name TextField
                            TextField("First Name", text: $firstName)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .focused($focusedField, equals: .firstName)
                            
                            // Last Name TextField
                            TextField("Last Name", text: $lastName)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        // Email TextField
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .focused($focusedField, equals: .email)
                        
                        // Password field with toggle visibility button
                        ZStack {
                            if showPassword {
                                // If showPassword is true, show TextField
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .padding(.trailing, 40) // Space for the button
                            } else {
                                // Otherwise, show SecureField
                                SecureField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .padding(.trailing, 40) // Space for the button
                            }
                            
                            // Trailing button to toggle password visibility
                            HStack {
                                Spacer()
                                Button {
                                    // Toggle the password visibility state
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                        
                        // Confirm Password field for Sign Up mode
                        if !isLogin {
                            // ZStack similar to Password field for confirming password
                            ZStack {
                                if showConfirmPassword {
                                    // Show TextField if visibility is on
                                    TextField("Confirm Password", text: $confirmPassword)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                        .padding(.trailing, 40)
                                } else {
                                    // Otherwise show SecureField
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                        .padding(.trailing, 40)
                                }
                                
                                // Trailing button to toggle confirm password visibility
                                HStack {
                                    Spacer()
                                    Button {
                                        showConfirmPassword.toggle()
                                    } label: {
                                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing, 10)
                                }
                            }
                        }
                        
                        // "Forgot Password?" button shown only in Login mode
                        if isLogin {
                            Button("Forgot Password?") {
                                // Show alert with password reset info
                                alertMessage = "Password reset instructions would be sent to your email."
                                showAlert = true
                            }
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.top, -8)
                        }
                        
                        // Action Button (Login or Signup)
                        Button(isLogin ? "Login" : "Sign Up") {
                            // Validate inputs common for both Login and Sign Up
                            if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                alertMessage = "Please fill in all fields."
                                showAlert = true
                                return
                            }
                            if !email.contains("@") || !email.contains(".") {
                                alertMessage = "Please enter a valid email address."
                                showAlert = true
                                return
                            }
                            
                            // Additional validation for Sign Up mode
                            if !isLogin {
                                // Check first name and last name are not empty
                                if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                    lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    alertMessage = "Please enter your first and last name."
                                    showAlert = true
                                    return
                                }
                                
                                // Check confirm password matches password
                                if confirmPassword != password {
                                    alertMessage = "Passwords do not match."
                                    showAlert = true
                                    return
                                }
                            }
                            
                            // MARK: - TempUser Authentication Check for Login
                            if isLogin {
                                // Check if user exists in registeredUsers
                                if let matchedUser = registeredUsers.first(where: { $0.userId == email && $0.password == password }) {
                                    // Credentials match, allow login and dismiss sheet with loading screen
                                    isLoggingIn = true
                                    showAuthSheet = false
                                    
                                    // Clear fields for next time
                                    email = ""
                                    password = ""
                                    showPassword = false
                                    
                                    // Save users in case there were any changes
                                    saveUsers()
                                    
                                    // Save logged in user for session persistence
                                    saveLoggedInUser(matchedUser)
                                    
                                    // After 8 seconds, transition to HomePage and stop loading
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                                        loggedInUser = matchedUser
                                        isLoggingIn = false
                                    }
                                } else {
                                    alertMessage = "Incorrect email or password."
                                    showAlert = true
                                    return
                                }
                            } else {
                                // MARK: - Append new user to registeredUsers on Sign Up
                                let newUser = TempUser(firstName: firstName, lastName: lastName, userId: email, password: password)
                                registeredUsers.append(newUser)
                                
                                // Save updated users list
                                saveUsers()
                                
                                // For Sign Up, dismiss sheet on success.
                                showAuthSheet = false
                                
                                // Clear fields for next time
                                email = ""
                                password = ""
                                showPassword = false
                                
                                // Clear sign up specific fields
                                firstName = ""
                                lastName = ""
                                confirmPassword = ""
                                showConfirmPassword = false
                            }
                        }
                        .buttonStyle(LiquidGlassButtonStyle())
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    .navigationTitle(isLogin ? "Login" : "Sign Up")
                    .toolbar {
                        // Dismiss button
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
                    // Alert for validation errors and info
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Invalid Input"),
                              message: Text(alertMessage),
                              dismissButton: .default(Text("OK")))
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        focusedField = isLogin ? .email : .firstName
                    }
                }
                .onChange(of: isLogin) { _, newValue in
                    DispatchQueue.main.async {
                        focusedField = newValue ? .email : .firstName
                    }
                }
            }
        }
        .onAppear {
            registeredUsers = loadUsers()
            // Check if user is already logged in
            if let savedUser = loadLoggedInUser() {
                loggedInUser = savedUser
            }
        }
        // Full screen cover for logging in loading screen
        .fullScreenCover(isPresented: $isLoggingIn) {
            LoggingInView()
        }
        // Full screen cover for HomePage after login
        .fullScreenCover(item: $loggedInUser, onDismiss: {
            loggedInUser = nil
        }) { user in
            HomePage(user: user, onLogout: {
                logout()
            })
        }
        
    // end of var body: some view
    }
    
    // MARK: - Helper functions for saving/loading users
    
    private func loadUsers() -> [TempUser] {
        guard let data = UserDefaults.standard.data(forKey: "registeredUsers") else {
            return [TempUser.default]
        }
        do {
            let decoded = try JSONDecoder().decode([TempUser].self, from: data)
            return decoded.isEmpty ? [TempUser.default] : decoded
        } catch {
            return [TempUser.default]
        }
    }
    
    private func saveUsers() {
        do {
            let encoded = try JSONEncoder().encode(registeredUsers)
            UserDefaults.standard.set(encoded, forKey: "registeredUsers")
        } catch {
            // Handle encoding error if needed, silent fail here
        }
    }
    
    // MARK: - Session Management
    
    private func saveLoggedInUser(_ user: TempUser) {
        do {
            let encoded = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encoded, forKey: "loggedInUser")
        } catch {
            print("Failed to save logged in user: \(error)")
        }
    }
    
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
    
    private func logout() {
        // Clear logged in user data
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        loggedInUser = nil
    }
    
// end of ContentView view. Ending point
}


#Preview {
    ContentView()
        
}
