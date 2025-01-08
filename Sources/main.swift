import Foundation

// MARK: - Configuration

enum ProjectConfig {
    static let projectName = "PickyEater2"
    static let projectPath = FileManager.default.currentDirectoryPath
    static let xcodeProjectPath = (projectPath as NSString).appendingPathComponent("\(projectName).xcodeproj")
}

// MARK: - Project Structure

let projectStructure = [
    "Models": [
        "Models.swift",
        "UserPreferences.swift",
    ],
    "Views": [
        "AuthenticationView.swift",
        "CuisineSelectionView.swift",
        "ContentView.swift",
        "HomeView.swift",
        "LocationSelectionView.swift",
        "PreferencesView.swift",
        "ProfileView.swift",
        "RestaurantDetailView.swift",
        "RestaurantListView.swift",
        "RestaurantMapView.swift",
        "RestaurantRowView.swift",
        "SearchView.swift",
        "SettingsView.swift",
        "MainTabView.swift",
        "ErrorView.swift",
    ],
    "ViewModels": [
        "AuthenticationService.swift",
        "LocationManager.swift",
        "NotificationManager.swift",
        "PreferencesManager.swift",
        "SignInWithAppleManager.swift",
        "ThemeManager.swift",
    ],
    "Services": [
        "RestaurantService.swift",
        "YelpAPIService.swift",
    ],
    "Utilities": [
        "ColorScheme.swift",
        "Config.swift",
        "NetworkError.swift",
        "NetworkMonitor.swift",
    ],
    "Components": [
        "SearchBar.swift",
        "SignInWithAppleButton.swift",
    ],
    "Resources": [
        "Assets.xcassets",
    ],
    "Supporting Files": [
        "PickyEater2.entitlements",
        "Info.plist",
    ],
]

// MARK: - Helper Functions

func shell(_ command: String) -> (output: String?, error: String?, exitCode: Int32) {
    let task = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    task.standardOutput = outputPipe
    task.standardError = errorPipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    let output = String(data: outputData, encoding: .utf8)
    let error = String(data: errorData, encoding: .utf8)

    return (output, error, task.terminationStatus)
}

func updateXcodeProject() {
    print("Updating Xcode project structure...")

    // First, let's clean the derived data
    let cleanCommand = """
    cd "\(ProjectConfig.projectPath)" && rm -rf ~/Library/Developer/Xcode/DerivedData/\(ProjectConfig.projectName)-* 2>/dev/null || true
    """

    _ = shell(cleanCommand)

    // Create directories and move files
    for (directory, files) in projectStructure {
        let dirPath = (ProjectConfig.projectPath as NSString).appendingPathComponent("\(ProjectConfig.projectName)/\(directory)")

        // Create directory
        let mkdirCommand = "mkdir -p '\(dirPath)'"
        _ = shell(mkdirCommand)

        // Move files
        for file in files {
            let sourcePath = (ProjectConfig.projectPath as NSString).appendingPathComponent("\(ProjectConfig.projectName)/\(file)")
            let destPath = (dirPath as NSString).appendingPathComponent(file)
            let mvCommand = "mv '\(sourcePath)' '\(destPath)' 2>/dev/null || true"
            _ = shell(mvCommand)
        }
    }

    // Create a backup of the project file
    let backupCommand = "cd \"\(ProjectConfig.projectPath)\" && cp -r \"\(ProjectConfig.projectName).xcodeproj\" \"\(ProjectConfig.projectName).xcodeproj.bak\""
    _ = shell(backupCommand)

    // Create a new project file
    let createProjectCommand = """
    cd "\(ProjectConfig.projectPath)" && \
    rm -rf "\(ProjectConfig.projectName).xcodeproj" && \
    swift package init --type executable && \
    swift package generate-xcodeproj
    """

    let createResult = shell(createProjectCommand)
    if createResult.exitCode != 0 {
        print("Error creating project: \(createResult.error ?? "Unknown error")")
        // Restore backup
        _ = shell("cd \"\(ProjectConfig.projectPath)\" && mv \"\(ProjectConfig.projectName).xcodeproj.bak\" \"\(ProjectConfig.projectName).xcodeproj\"")
        return
    }

    // Add all files to the project
    var addFilesCommands: [String] = []

    for (directory, files) in projectStructure {
        for file in files {
            let filePath = "\(ProjectConfig.projectName)/\(directory)/\(file)"
            let command = "cd \"\(ProjectConfig.projectPath)\" && xcodebuild -project \"\(ProjectConfig.projectName).xcodeproj\" -target \"\(ProjectConfig.projectName)\" build SOURCE_ROOT=\"\(ProjectConfig.projectPath)\" SWIFT_INCLUDE_PATHS=\"\(ProjectConfig.projectPath)/\(ProjectConfig.projectName)/\(directory)\""
            addFilesCommands.append(command)
        }
    }

    let addFilesCommand = addFilesCommands.joined(separator: " && ")

    let addResult = shell(addFilesCommand)
    if addResult.exitCode != 0 {
        print("Error adding files to project: \(addResult.error ?? "Unknown error")")
        // Restore backup
        _ = shell("cd \"\(ProjectConfig.projectPath)\" && mv \"\(ProjectConfig.projectName).xcodeproj.bak\" \"\(ProjectConfig.projectName).xcodeproj\"")
        return
    }

    // Build the project
    let buildCommand = """
    cd "\(ProjectConfig.projectPath)" && xcodebuild -project "\(ProjectConfig.projectName).xcodeproj" -scheme "\(ProjectConfig.projectName)" clean build -destination 'platform=iOS Simulator,name=iPhone 16 Pro' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
    """

    let buildResult = shell(buildCommand)
    if buildResult.exitCode == 0 {
        print("Successfully built project")
        // Remove backup
        _ = shell("cd \"\(ProjectConfig.projectPath)\" && rm -rf \"\(ProjectConfig.projectName).xcodeproj.bak\"")
    } else {
        print("Error building project: \(buildResult.error ?? "Unknown error")")
        // Restore backup
        _ = shell("cd \"\(ProjectConfig.projectPath)\" && mv \"\(ProjectConfig.projectName).xcodeproj.bak\" \"\(ProjectConfig.projectName).xcodeproj\"")
    }
}

// MARK: - Main Execution

print("Starting project file update...")
updateXcodeProject()
print("\nProject file update complete!")
