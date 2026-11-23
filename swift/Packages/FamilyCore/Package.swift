// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FamilyCore",
  defaultLocalization: "en",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "FamilyCore", targets: ["FamilyCore"]),
    .library(name: "FamilyData", targets: ["FamilyData"]),
  ],
  dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.55.0"),
  ],
  targets: [
    // Entities, scoring, standings, win series and records. No I/O.
    .target(name: "FamilyCore"),
    // Supabase repository for the fg_ tables and RPCs.
    .target(
      name: "FamilyData",
      dependencies: [
        "FamilyCore",
        .product(name: "Supabase", package: "supabase-swift"),
      ]
    ),
    .testTarget(name: "FamilyCoreTests", dependencies: ["FamilyCore"]),
  ]
)
