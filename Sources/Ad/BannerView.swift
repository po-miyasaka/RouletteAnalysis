//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/25.
//

import SwiftUI

public enum Place: String {
    case settingBottom = "setting_bottom"
    case rouletteTab = "roulette_tab"
    case wheelTabBottom = "wheel_tab_bottom"

    var adUnitID: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let id = dictionary[rawValue] as? String else {
            print("□■□■□■□■□■□■□■□■□■□■")
            print("please set valid adUnitID")
            print("□■□■□■□■□■□■□■□■□■□■")
            return "ca-app-pub-3940256099942544/2934735716" // default value is a testID
        }
        return id
    }
}

#if canImport(GoogleMobileAds)

    @_exported import GoogleMobileAds
    import UIKit

    public struct AdBannerView: UIViewRepresentable {
        let delegate = Delegate()

        let place: Place

        public init(place: Place) {
            self.place = place
        }

        public func makeUIView(context _: Context) -> UIView {
            let view = GADBannerView(adSize: GADAdSizeBanner)
            view.delegate = delegate
            view.adUnitID = place.adUnitID
            //        "ca-app-pub-6326437184905669/6995299249"
            view.load(GADRequest())
            
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                let keyWindow = windowScene.windows.first { $0.isKeyWindow }
                view.rootViewController = keyWindow?.rootViewController
            }
            return view
        }

        public func updateUIView(_: UIView, context _: Context) {}

        class Delegate: NSObject, GADBannerViewDelegate {
            func bannerViewDidReceiveAd(_: GADBannerView) {
                print("bannerViewDidReceiveAd")
            }

            func bannerView(_: GADBannerView, didFailToReceiveAdWithError error: Error) {
                print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
            }
        }
    }

    // #else
//
//    public struct AdBannerView: View {
//        let place: Place
//        public init(place: Place) {
//            self.place = place
//        }
//
//        public var body: some View {
//            EmptyView()
//        }
//    }

#endif
