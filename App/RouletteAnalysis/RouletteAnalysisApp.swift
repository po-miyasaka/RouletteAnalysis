//
//  RouletteAnalysisApp.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import AppView
import App
#if canImport(Ad)
import Ad
#endif
import SwiftUI


#if os(macOS)
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        FirebaseApp.configure()
    }
}
#else
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if let googleAppID {
            FirebaseApp.configure()
#if canImport(Ad)
            
            GADMobileAds.sharedInstance().start(completionHandler: nil)
#endif
        }
        return true
    }
    
}

var googleAppID: String? {
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let productionInfoDict = NSDictionary(contentsOfFile: path) as? [String: Any],
          let id = productionInfoDict["GOOGLE_APP_ID"] as? String,
            id != "dummy"
    else {
        return nil
    }
    return id
}
#endif

@main
struct RouletteAnalysisApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#else
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
#if os(macOS)
            AppView(
                store: Store(initialState: AppFeature.State(),
                reducer: AppFeature())
            )
#else
            NavigationView {
                AppView(store: Store(initialState: AppFeature.State(), reducer: AppFeature()))
            }
#endif
        }
    }
}
