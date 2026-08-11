// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "whatsapp_stickers_injector",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "whatsapp-stickers-injector", targets: ["whatsapp_stickers_injector"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.6")
    ],
    targets: [
        .target(
            name: "whatsapp_stickers_injector",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder")
            ]
        )
    ]
)
