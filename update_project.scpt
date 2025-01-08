tell application "Xcode"
    open "/Users/abusiddique/PickyEater2/PickyEater2.xcodeproj"
    delay 2
    
    tell application "System Events"
        tell process "Xcode"
            click menu item "Add Files to \"\(ProjectConfig.projectName)\"..." of menu "File" of menu bar 1
            delay 1
            
            -- Navigate to each directory and select files
            -- Create and select Resources directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Resources'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/Assets.xcassets' '/Users/abusiddique/PickyEater2/PickyEater2/Resources/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Resources"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select Utilities directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Utilities'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/ColorScheme.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Utilities/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/Config.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Utilities/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/NetworkError.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Utilities/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/NetworkMonitor.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Utilities/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Utilities"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select Services directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Services'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/RestaurantService.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Services/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/YelpAPIService.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Services/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Services"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select ViewModels directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/AuthenticationService.swift' '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/LocationManager.swift' '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/NotificationManager.swift' '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/PreferencesManager.swift' '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/SignInWithAppleManager.swift' '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/ThemeManager.swift' '/Users/abusiddique/PickyEater2/PickyEater2/ViewModels/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/ViewModels"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select Supporting Files directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Supporting Files'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/PickyEater2.entitlements' '/Users/abusiddique/PickyEater2/PickyEater2/Supporting Files/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/Info.plist' '/Users/abusiddique/PickyEater2/PickyEater2/Supporting Files/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Supporting Files"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select Components directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Components'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/SearchBar.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Components/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/SignInWithAppleButton.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Components/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Components"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select Views directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Views'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/AuthenticationView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/CuisineSelectionView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/ContentView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/HomeView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/LocationSelectionView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/PreferencesView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/ProfileView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/RestaurantDetailView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/RestaurantListView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/RestaurantMapView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/RestaurantRowView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/SearchView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/SettingsView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/MainTabView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/ErrorView.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Views/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Views"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1

-- Create and select Models directory
do shell script "mkdir -p '/Users/abusiddique/PickyEater2/PickyEater2/Models'"

-- Move files to the directory
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/Models.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Models/' 2>/dev/null || true"
do shell script "mv '/Users/abusiddique/PickyEater2/PickyEater2/UserPreferences.swift' '/Users/abusiddique/PickyEater2/PickyEater2/Models/' 2>/dev/null || true"

-- Select the directory in the file dialog
keystroke "g" using {command down, shift down}
delay 0.5
keystroke "/Users/abusiddique/PickyEater2/PickyEater2/Models"
delay 0.5
click button "Go" of sheet 1 of window 1
delay 0.5

-- Select all files in the directory
keystroke "a" using {command down}
delay 0.5

-- Click Add
click button "Add" of sheet 1 of window 1
delay 1
        end tell
    end tell
    
    delay 2
    save
    delay 2
    quit
end tell