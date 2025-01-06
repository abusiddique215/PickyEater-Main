import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @StateObject private var signInManager = SignInWithAppleManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(colors.primary)
                        
                        Text(signInManager.userName ?? "Guest User")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colors.text)
                        
                        if let email = signInManager.userEmail {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(colors.secondary)
                        }
                        
                        SignInWithAppleButton()
                    }
                    .padding(.vertical, 32)
                    
                    // Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preferences")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 2) {
                            NavigationLink(destination: CuisineSelectionView(preferences: .constant(UserPreferences()))) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 30)
                                    
                                    Text("Favorite Cuisines")
                                        .foregroundColor(colors.text)
                                    
                                    Spacer()
                                    
                                    Text("Update")
                                        .foregroundColor(colors.primary)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(colors.secondary)
                                }
                                .padding()
                            }
                            
                            Divider().background(Color(white: 0.2))
                            
                            Button {
                                // Handle location settings
                            } label: {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    Text("Default Location")
                                        .foregroundColor(colors.text)
                                    
                                    Spacer()
                                    
                                    Text("Change")
                                        .foregroundColor(colors.primary)
                                }
                                .padding()
                            }
                            
                            Divider().background(Color(white: 0.2))
                            
                            Button {
                                // Handle price range
                            } label: {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 30)
                                    
                                    Text("Price Range")
                                        .foregroundColor(colors.text)
                                    
                                    Spacer()
                                    
                                    Text("$$$")
                                        .foregroundColor(colors.primary)
                                }
                                .padding()
                            }
                        }
                        .background(colors.cardBackground)
                        .cornerRadius(16)
                    }
                    
                    // App Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Settings")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 2) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                
                                Text("Dark Mode")
                                    .foregroundColor(colors.text)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { themeManager.colorScheme == .dark },
                                    set: { _ in themeManager.toggleTheme() }
                                ))
                                .tint(colors.primary)
                            }
                            .padding()
                            
                            Divider().background(Color(white: 0.2))
                            
                            Button {
                                // Handle notifications
                            } label: {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.orange)
                                        .frame(width: 30)
                                    
                                    Text("Notifications")
                                        .foregroundColor(colors.text)
                                    
                                    Spacer()
                                    
                                    Text("Configure")
                                        .foregroundColor(colors.primary)
                                }
                                .padding()
                            }
                        }
                        .background(colors.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
} 