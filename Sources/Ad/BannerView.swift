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
    
    var adUnitID: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let id = dictionary[self.rawValue] as? String else {
            print("□■□■□■□■□■□■□■□■□■□■")
            print("please set valid adUnitID")
            print("□■□■□■□■□■□■□■□■□■□■")
            return "ca-app-pub-3940256099942544/2934735716"  // default value is a testID
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
    
    public func makeUIView(context: Context) -> UIView {

        let view = GADBannerView(adSize: GADAdSizeBanner)
        view.delegate = delegate
        view.adUnitID = place.adUnitID
        //        "ca-app-pub-6326437184905669/6995299249"
        view.load(GADRequest())
        view.rootViewController = UIApplication.shared.windows.first?.rootViewController
        return view

        
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
    class Delegate: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("bannerViewDidReceiveAd")
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }
    }
}

#else

public struct AdBannerView: View {
    
    let place: Place
    public init(place: Place) {
        self.place = place
    }
    public var body: some View {
        EmptyView()
    }
}

#endif
