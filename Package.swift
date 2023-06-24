// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let composableArchitecture: Target.Dependency = .product(
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
)
let firebaseCrashlytics: Target.Dependency = .product(
    name: "FirebaseCrashlytics",
    package: "firebase-ios-sdk"
)
let firebaseCore: Target.Dependency = .product(
    name: "FirebaseCore",
    package: "firebase-ios-sdk"
)

enum TargetName {
    case APIClient
    case App
    case AppView
    case Feedback
    case History
    case HistoryView
    case Item
    case TableLayout
    case TableLayoutView
    case Roulette
    case RouletteView
    case Setting
    case SettingView
    case Tutorial
    case UserDefaultsClient
    case Utility
    case Wheel
    case WheelView
    case other(Target.Dependency)
    var dependency: Target.Dependency {
        if let nameString = self.nameString {
            return Target.Dependency(stringLiteral: nameString)
        } else if case .other(let element) = self {
            return element
        } else {
            fatalError("owata")
        }
    }
    
    var nameString: String? {
        switch self {
            
        case .APIClient:
            return "APIClient"
        case .App:
            return "App"
        case .Feedback:
            return "Feedback"
        case .History:
            return "History"
        case .HistoryView:
            return "HistoryView"
        case .Item:
            return "Item"
        case .TableLayout:
            return "TableLayout"
        case .TableLayoutView:
            return "TableLayoutView"
        case .Roulette:
            return "Roulette"
        case .RouletteView:
            return "RouletteView"
        case .AppView:
            return "AppView"
        case .Setting:
            return "Setting"
        case .SettingView:
            return "SettingView"
        case .Tutorial:
            return "Tutorial"
        case .UserDefaultsClient:
            return "UserDefaultsClient"
        case .Utility:
            return "Utility"
        case .Wheel:
            return "Wheel"
        case .WheelView:
            return "WheelView"
        case .other:
            return nil
        }
    }
}


let package = Package(
    name: "RouletteFeature",
    platforms: [.iOS(SupportedPlatform.IOSVersion.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: TargetName.AppView.nameString!,
            targets: [TargetName.AppView.nameString!]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.53.2")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        target(
            name: .AppView,
            dependencies: [
                .UserDefaultsClient,
                .Tutorial,
                .Feedback,
                .App,
                .Setting,
                .Wheel,
                .TableLayout,
                .Roulette,
                .SettingView,
                .RouletteView,
                .other(composableArchitecture),
                .other(firebaseCrashlytics),
//                .other(firebaseCore)
            ]
        ),
        target(
            name: .Item
        ),
        target(
            name: .App,
            dependencies: [
                .Item,
                .Setting,
                .Roulette,
                .UserDefaultsClient,
                .other(composableArchitecture)]
        ),
        target(
            name: .Tutorial,
            dependencies: [.Utility]
        ),
        
        target(
            name: .Setting,
            dependencies: [.UserDefaultsClient,
                           .Item,
                           .other(composableArchitecture)]
        ),
        target(
            name: .SettingView,
            dependencies: [
                           .Item,
                           .Setting,
                           .Tutorial,
                           .Feedback,
                           .other(composableArchitecture)]
        ),
        target(
            name: .Roulette,
            dependencies: [.TableLayout,
                           .Wheel,
                           .History,
                           .Setting,
                           .other(composableArchitecture)]
        ),
        target(
            name: .RouletteView,
            dependencies: [.TableLayout,
                           .Wheel,
                           .History,
                           .Setting,
                           .TableLayoutView,
                           .Roulette,
                           .HistoryView,
                           .WheelView,
                           .other(composableArchitecture)]
        ),
        target(
            name: .TableLayout,
            dependencies: [
                           .History,
                           .Setting,
                           .Item,
                           .other(composableArchitecture)]
        ),
        target(
            name: .TableLayoutView,
            dependencies: [
                           .History,
                           .Setting,
                           .Item,
                           .TableLayout,
                           .Roulette,
                           .Utility,
                           .other(composableArchitecture)]
        ),
        target(
            name: .Wheel,
            dependencies: [.History,
                           .Setting,
                           .Item,
                           .other(composableArchitecture)]
        ),
        target(
            name: .WheelView,
            dependencies: [.History,
                           .Setting,
                           .Item,
                           .Wheel,
                           .Utility,
                           .Roulette,
                           .other(composableArchitecture)]
        ),
        target(
            name: .History,
            dependencies: [.UserDefaultsClient,
                           .Item,
                           .other(composableArchitecture)]
        ),
        target(
            name: .HistoryView,
            dependencies: [
                           .Item,
                           .History,
                           .other(composableArchitecture)]
        ),
        target(
            name: .Utility
        ),
        target(
            name: .APIClient
        ),
        target(
            name: .Feedback,
            dependencies: [
                .Utility,
                .APIClient,
                .other(composableArchitecture)
            ]
        ),
        target(
            name: .UserDefaultsClient,
            dependencies: [
                .other(composableArchitecture)
            ]
        ),
        .testTarget(
            name: "RouletteFeatureTests",
            dependencies: ["AppView",
                           composableArchitecture]
        )
    ]
)


func target(name: TargetName, dependencies: [TargetName] = []) -> Target {
    let dependencies = dependencies.map(\.dependency)
    return .target(name: name.nameString ?? "", dependencies: dependencies)
}

//func library(target: TargetName, dependencies: [TargetName] = [], others: [Array<Target.Dependency>.ArrayLiteralElement] ) -> Product {
//    let dependencies = dependencies.map(\.depedency) + others
//    return .library(name: target.nameString ?? "", targets: dependencies)
//}
