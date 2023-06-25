//
//  RouletteAnalysisApp.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
@_exported import AppView
import App
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
            FirebaseApp.configure()
            return true
        }
    
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
            AppView(store: Store(initialState: AppFeature.State(), reducer: AppFeature()))
            #else
                NavigationView {
                    AppView(store: Store(initialState: AppFeature.State(), reducer: AppFeature()))
                }
            #endif
        }
    }
}
