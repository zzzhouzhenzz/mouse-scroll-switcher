// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MouseScrollSwitcher",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "MouseScrollSwitcher",
            targets: ["MouseScrollSwitcher"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "MouseScrollSwitcher",
            path: ".",
            exclude: [
                "AGENTS.md",
                "Info.plist",
                "LICENSE",
                "Makefile",
                "README.md",
                "assets",
                "tests.swift",
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-downgrade-typecheck-interface-error",
                ]),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("UserNotifications"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
