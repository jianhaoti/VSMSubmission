// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "VSMSubmission",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "VSMSubmission",
            targets: ["AppModule"],
            bundleIdentifier: "PaulTee.VSMSubmission",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .butterfly),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources") // Include all files in the Resources folder
            ]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)