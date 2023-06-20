//
//  RouletteAnalysisApp.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import AppView
import App
import SwiftUI
#if os(macOS)
#else
    final class AppDelegate: NSObject, UIApplicationDelegate {
        func application(
            _: UIApplication,
            didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            return true
        }
    
    }
#endif

@main
struct RouletteAnalysisApp: App {
    #if os(macOS)
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
