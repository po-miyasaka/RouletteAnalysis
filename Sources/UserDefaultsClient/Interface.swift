import Dependencies
import Foundation

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public struct UserDefaultsClient {
    public var boolForKey: @Sendable (String) -> Bool
    public var dataForKey: @Sendable (String) -> Data?
    public var stringForKey: @Sendable (String) -> String?
    public var doubleForKey: @Sendable (String) -> Double
    public var integerForKey: @Sendable (String) -> Int
    public var remove: @Sendable (String) async -> Void
    public var setBool: @Sendable (Bool, String) async -> Void
    public var setData: @Sendable (Data?, String) async -> Void
    public var setString: @Sendable (String?, String) async -> Void
    public var setDouble: @Sendable (Double, String) async -> Void
    public var setInteger: @Sendable (Int, String) async -> Void
    
    public var omomiWidthForPrediction: String? {
        self.stringForKey(omomiWidthForPredictionKey)
    }
    
    public func setOmoiWidthForPrediction(_ value: String) async {
        await self.setString(value, omomiWidthForPredictionKey)
    }
    
    public var omomiWidthForHistory: String? {
        self.stringForKey(omomiWidthForHistoryKey)
    }
    
    public func setOmoiWidthForHistory(_ value: String) async {
        await self.setString(value, omomiWidthForHistoryKey)
    }
    
    public var defaultDisplayedHistoryLimit: Int? {
        let value = self.integerForKey(defaultDisplayedHistoryLimitKey)
        return value == 0 ? nil : value
    }
    
    public func setDefaultDisplayedHistoryLimitKey(_ value: Int) async {
        await self.setInteger(value, defaultDisplayedHistoryLimitKey)
    }
    
    public var rule: String? {
        self.stringForKey(ruleKey)
    }
    
    public func setRule(_ string: String) async {
        await self.setString(string, ruleKey)
    }
    
    public var didFirstLaunch: Bool {
        self.boolForKey(didFirstLaunchKey)
    }
    
    public func setDidFirstLaunch() async {
        await self.setBool(true, didFirstLaunchKey)
    }
}

public let omomiWidthForPredictionKey = "omomiWidthForPredictionKey"
public let omomiWidthForHistoryKey = "omomiWidthForHistoryKey"
public let ruleKey = "ruleKey"
public let defaultDisplayedHistoryLimitKey = "defaultDisplayedHistoryLimitKey"
public let didFirstLaunchKey = "didFirstLaunchKey"
