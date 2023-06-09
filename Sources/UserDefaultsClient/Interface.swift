import Dependencies
import Foundation

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public struct UserDefaultsClient {
    public var boolForKey: @Sendable(String) -> Bool
    public var dataForKey: @Sendable(String) -> Data?
    public var stringForKey: @Sendable(String) -> String?
    public var doubleForKey: @Sendable(String) -> Double
    public var integerForKey: @Sendable(String) -> Int
    public var remove: @Sendable(String) async -> Void
    public var setBool: @Sendable(Bool, String) async -> Void
    public var setData: @Sendable(Data?, String) async -> Void
    public var setString: @Sendable(String?, String) async -> Void
    public var setDouble: @Sendable(Double, String) async -> Void
    public var setInteger: @Sendable(Int, String) async -> Void

    public var omomiWidthForPrediction: String? {
        stringForKey(omomiWidthForPredictionKey)
    }

    public func setOmoiWidthForPrediction(_ value: String) async {
        await setString(value, omomiWidthForPredictionKey)
    }

    public var omomiWidthForHistory: String? {
        stringForKey(omomiWidthForHistoryKey)
    }

    public func setOmoiWidthForHistory(_ value: String) async {
        await setString(value, omomiWidthForHistoryKey)
    }

    public var defaultDisplayedHistoryLimit: Int? {
        let value = integerForKey(defaultDisplayedHistoryLimitKey)
        return value == 0 ? nil : value
    }

    public func setDefaultDisplayedHistoryLimit(_ value: Int) async {
        await setInteger(value, defaultDisplayedHistoryLimitKey)
    }
    
    public var screenLayout: String? {
        let value = stringForKey(screenLayoutKey)
        return value
    }

    public func setScreenLayout(_ value: String) async {
        await setString(value, screenLayoutKey)
    }

    public var rule: String? {
        stringForKey(ruleKey)
    }

    public func setRule(_ string: String) async {
        await setString(string, ruleKey)
    }

    public var didFirstLaunch: Bool {
        boolForKey(didFirstLaunchKey)
    }

    public func setDidFirstLaunch() async {
        await setBool(true, didFirstLaunchKey)
    }
}

let omomiWidthForPredictionKey = "omomiWidthForPredictionKey"
let omomiWidthForHistoryKey = "omomiWidthForHistoryKey"
let ruleKey = "ruleKey"
let defaultDisplayedHistoryLimitKey = "defaultDisplayedHistoryLimitKey"
let didFirstLaunchKey = "didFirstLaunchKey"
let screenLayoutKey = "screenLayoutKey"
