import ProjectDescription

let project = Project(
    name: "PickyEater2",
    organizationName: "babubhaisab",
    options: .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: false,
        disableSynthesizedResourceAccessors: false
    ),
    packages: [],
    settings: .settings(
        base: [:],
        configurations: [
            .debug(name: "Debug", settings: [:], xcconfig: nil),
            .release(name: "Release", settings: [:], xcconfig: nil),
        ],
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "PickyEater2",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "babubhaisab.PickyEater2",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .file(path: "PickyEater2/Supporting Files/Info.plist"),
            sources: [
                "PickyEater2/Models/**",
                "PickyEater2/Views/**",
                "PickyEater2/ViewModels/**",
                "PickyEater2/Services/**",
                "PickyEater2/Utilities/**",
                "PickyEater2/Components/**",
                "PickyEater2/PickyEater2App.swift",
                "PickyEater2/AppDelegate.swift",
            ],
            resources: [
                "PickyEater2/Resources/**",
                "PickyEater2/Preview Content/**",
            ],
            entitlements: "PickyEater2/Supporting Files/PickyEater2.entitlements",
            scripts: [
                .pre(
                    script: """
                    if which swiftformat >/dev/null; then
                        swiftformat .
                    else
                        echo "warning: SwiftFormat not installed"
                    fi
                    """,
                    name: "SwiftFormat"
                ),
            ],
            dependencies: []
        ),
        .target(
            name: "PickyEater2Tests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "babubhaisab.PickyEater2Tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["PickyEater2Tests/**"],
            dependencies: [
                .target(name: "PickyEater2"),
            ]
        ),
        .target(
            name: "PickyEater2UITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "babubhaisab.PickyEater2UITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["PickyEater2UITests/**"],
            dependencies: [
                .target(name: "PickyEater2"),
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "PickyEater2",
            shared: true,
            buildAction: .buildAction(targets: ["PickyEater2"]),
            testAction: .targets(["PickyEater2Tests", "PickyEater2UITests"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
    ]
)
