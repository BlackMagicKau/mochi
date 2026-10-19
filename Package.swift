// swift-tools-version:5.9
// Modified for Mochi: names and identities; original attribution in NOTICE.
import PackageDescription

let package = Package(
    name: "Mochi",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .executable(name: "MochiHost", targets: ["MochiHostCLI"]),
        .executable(name: "MochiMenuBar", targets: ["MochiMenuBar"]),
        .library(name: "StreamProtocol", targets: ["StreamProtocol"]),
    ],
    targets: [
        .target(name: "StreamProtocol"),
        // The Mac host itself (capture, encode, network, input, virtual display), shared by the CLI
        // and the menu bar app; they reach it through `package` access.
        .target(name: "MochiHostCore", dependencies: ["StreamProtocol"], path: "Sources/MochiHost"),
        // The command-line host: flags, the run loop, the Terminal permission hint.
        .executableTarget(name: "MochiHostCLI", dependencies: ["MochiHostCore", "StreamProtocol"]),
        // The menu bar app: status item, Settings and Log windows (AppKit lifecycle, SwiftUI panes).
        .executableTarget(name: "MochiMenuBar", dependencies: ["MochiHostCore", "StreamProtocol"]),
        // Milestone 3 spike: virtual display + window move + capture. Its VirtualDisplay.swift
        // is a symlink to the host's copy. Not shipped.
        .executableTarget(name: "CaptureProbe"),
        .executableTarget(name: "VirtualDisplayProbe"),
    ]
)
