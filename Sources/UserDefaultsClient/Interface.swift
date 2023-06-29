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

    public var weightWidthForPrediction: String? {
        stringForKey(weightWidthForPredictionKey)
    }

    public func setWeightWidthForPrediction(_ value: String) async {
        await setString(value, weightWidthForPredictionKey)
    }

    public var weightWidthForHistory: String? {
        stringForKey(weightWidthForHistoryKey)
    }

    public func setWeightWidthForHistory(_ value: String) async {
        await setString(value, weightWidthForHistoryKey)
    }

    public var defaultDisplayedHistoryLimit: Int? {
        let value = integerForKey(defaultDisplayedHistoryLimitKey)
        return value == 0 ? nil : value
    }

    public func setDefaultDisplayedHistoryLimit(_ value: Int) async {
        await setInteger(value, defaultDisplayedHistoryLimitKey)
    }

    public var isHidingAd: Bool {
        boolForKey(isHidingAdKey)
    }

    public func setIsHidingAd(_ value: Bool) async {
        await setBool(value, isHidingAdKey)
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

    public var roulettes: Data? {
        dataForKey(roulettesKey)
    }

    public func setRoulettes(data: Data?) async {
        await setData(data, roulettesKey)
    }
}

let weightWidthForPredictionKey = "weightWidthForPredictionKey"
let weightWidthForHistoryKey = "weightWidthForHistoryKey"
let ruleKey = "ruleKey"
let roulettesKey = "roulettesKey"
let defaultDisplayedHistoryLimitKey = "defaultDisplayedHistoryLimitKey"
let didFirstLaunchKey = "didFirstLaunchKey"
let screenLayoutKey = "screenLayoutKey"
let isHidingAdKey = "isHidingAdKey"
