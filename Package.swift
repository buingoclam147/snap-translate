// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ESnap",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ESnap", targets: ["ESnap"])
    ],
    targets: [
        .executableTarget(
            name: "ESnap",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Vision"),
                .linkedFramework("Combine"),
                .linkedFramework("CoreGraphics")
            ]
        )
    ]
)
