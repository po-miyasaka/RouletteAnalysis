//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/05.
//

import Foundation

public extension Bundle {
    var releaseVersionNumber: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var buildVersionNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
