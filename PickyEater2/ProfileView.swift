import SwiftUI

struct ProfileView: View {
    // Modern color scheme (matching our other views)
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),     // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),   // Light gray
        text: Color.white,
        cardBackground: Color(white: 0.12)                       // Slightly lighter than black
    )
    
    @State private var isEditingProfile = false
    @AppStorage("userName") private var userName = "Guest User"
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(colors.primary)
                        
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colors.text)
                        
                        if !userEmail.isEmpty {
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(colors.secondary)
                        }
                        
                        Button {
                            isEditingProfile.toggle()
                        } label: {
                            Text("Edit Profile")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(colors.text)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(colors.cardBackground)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(colors.primary, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.vertical, 32)
                    
                    // Settings Sections
                    VStack(spacing: 24) {
                        // Preferences Section
                        SettingsSection(title: "Preferences") {
                            VStack(spacing: 0) {
                                SettingsRow(icon: "heart.fill", title: "Favorite Cuisines", color: .red) {
                                    NavigationLink {
                                        CuisineSelectionView(preferences: .constant(UserPreferences()))
                                    } label: {
                                        HStack {
                                            Text("Update")
                                            Image(systemName: "chevron.right")
                                        }
                                        .foregroundColor(colors.primary)
                                    }
                                }
                                
                                SettingsRow(icon: "location.fill", title: "Default Location", color: .blue) {
                                    Button {
                                        // Handle location settings
                                    } label: {
                                        Text("Change")
                                            .foregroundColor(colors.primary)
                                    }
                                }
                                
                                SettingsRow(icon: "dollarsign.circle.fill", title: "Price Range", color: .green) {
                                    Button {
                                        // Handle price range
                                    } label: {
                                        Text("$$$")
                                            .foregroundColor(colors.primary)
                                    }
                                }
                            }
                        }
                        
                        // App Settings Section
                        SettingsSection(title: "App Settings") {
                            VStack(spacing: 0) {
                                SettingsRow(icon: "moon.fill", title: "Dark Mode", color: .purple) {
                                    Toggle("", isOn: $isDarkMode)
                                        .tint(colors.primary)
                                }
                                
                                SettingsRow(icon: "bell.fill", title: "Notifications", color: .orange) {
                                    Button {
                                        // Handle notifications
                                    } label: {
                                        Text("Configure")
                                            .foregroundColor(colors.primary)
                                    }
                                }
                            }
                        }
                        
                        // Account Section
                        SettingsSection(title: "Account") {
                            VStack(spacing: 0) {
                                SettingsRow(icon: "envelope.fill", title: "Email", color: .blue) {
                                    Text(userEmail.isEmpty ? "Add Email" : userEmail)
                                        .foregroundColor(colors.secondary)
                                }
                                
                                SettingsRow(icon: "lock.fill", title: "Password", color: .gray) {
                                    Button {
                                        // Handle password change
                                    } label: {
                                        Text("Change")
                                            .foregroundColor(colors.primary)
                                    }
                                }
                                
                                SettingsRow(icon: "arrow.right.square.fill", title: "Sign Out", color: colors.primary) {
                                    Button {
                                        // Handle sign out
                                    } label: {
                                        Text("Sign Out")
                                            .foregroundColor(colors.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(userName: $userName, userEmail: $userEmail)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            VStack(spacing: 2) {
                content()
            }
            .background(Color(white: 0.12))
            .cornerRadius(16)
        }
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            content()
        }
        .padding()
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userEmail: String
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $tempName)
                    TextField("Email", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        userName = tempName
                        userEmail = tempEmail
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempName = userName
                tempEmail = userEmail
            }
        }
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
} 