// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SnapTranslate",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "SnapTranslate", targets: ["SnapTranslate"])
    ],
    targets: [
        .executableTarget(
            name: "SnapTranslate",
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
