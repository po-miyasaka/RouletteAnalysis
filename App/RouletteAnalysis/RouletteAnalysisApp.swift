//
//  RouletteAnalysisApp.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import RouletteFeature
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

                HomeView(store: Store(initialState: Roulette.State(), reducer: Roulette()))

            #else
                NavigationView {
                    HomeView(store: Store(initialState: Roulette.State(), reducer: Roulette()))
                }
            #endif
        }
    }
}
