// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TSnap",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "TSnap", targets: ["TSnap"])
    ],
    targets: [
        .executableTarget(
            name: "TSnap",
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
