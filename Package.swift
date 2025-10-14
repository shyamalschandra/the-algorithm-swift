// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TwitterAlgorithm",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11),
        .tvOS(.v18)
    ],
    products: [
        .library(name: "TwitterAlgorithmCore", targets: ["TwitterAlgorithmCore"]),
        .library(name: "TwitterAlgorithmUI", targets: ["TwitterAlgorithmUI"]),
        .library(name: "TwitterAlgorithmML", targets: ["TwitterAlgorithmML"]),
        .executable(name: "TwitterAlgorithmDemo", targets: ["TwitterAlgorithmDemo"]),
        .executable(name: "TwitterAlgorithmCocoa", targets: ["TwitterAlgorithmCocoa"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "TwitterAlgorithmCore",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .target(
            name: "TwitterAlgorithmML",
            dependencies: [
                "TwitterAlgorithmCore",
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .target(
            name: "TwitterAlgorithmUI",
            dependencies: [
                "TwitterAlgorithmCore",
                "TwitterAlgorithmML"
            ]
        ),
        .executableTarget(
            name: "TwitterAlgorithmDemo",
            dependencies: [
                "TwitterAlgorithmCore",
                "TwitterAlgorithmML",
                "TwitterAlgorithmUI",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "TwitterAlgorithmCocoa",
            dependencies: [
                "TwitterAlgorithmCore",
                "TwitterAlgorithmML",
                "TwitterAlgorithmUI"
            ]
        ),
        .testTarget(
            name: "TwitterAlgorithmCoreTests",
            dependencies: ["TwitterAlgorithmCore"]
        ),
        .testTarget(
            name: "TwitterAlgorithmMLTests",
            dependencies: ["TwitterAlgorithmML"]
        ),
        .testTarget(
            name: "TwitterAlgorithmUITests",
            dependencies: ["TwitterAlgorithmUI"]
        )
    ]
)
