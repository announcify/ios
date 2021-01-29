// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "announcify",
    // platforms: [
    //     .iOS(.v10), //TODO: allow all
    // ],
    products: [
        .library(
            name: "announcify",
            targets: ["announcify"]
        ),
    ],
    targets: [
        .target(
            name: "announcify",
            path: "announcify",
            dependencies: []
        ),
    ],
    dependencies: []
)





// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "DeckOfPlayingCards",
    products: [
        .library(name: "DeckOfPlayingCards", targets: ["DeckOfPlayingCards"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/example-package-fisheryates.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/example-package-playingcard.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "DeckOfPlayingCards",
            dependencies: ["FisherYates", "PlayingCard"]),
        .testTarget(
            name: "DeckOfPlayingCardsTests",
            dependencies: ["DeckOfPlayingCards"]),
    ]
)