// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SDP",
  products: [
    .library(name: "SDP", targets: ["SDP"])
  ],
  targets: [
    .target(name: "SDP", dependencies: []),
    .target(name: "SDPExamples", dependencies: ["SDP"]),
    .testTarget(name: "SDPTests", dependencies: ["SDP"]),
  ]
)
