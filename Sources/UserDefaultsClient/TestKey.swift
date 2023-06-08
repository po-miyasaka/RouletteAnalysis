import Dependencies
import Foundation

extension UserDefaultsClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        boolForKey: unimplemented("\(Self.self).boolForKey", placeholder: false),
        dataForKey: unimplemented("\(Self.self).dataForKey", placeholder: nil),
        stringForKey: unimplemented("\(Self.self).stringForKey", placeholder: nil),
        doubleForKey: unimplemented("\(Self.self).doubleForKey", placeholder: 0),
        integerForKey: unimplemented("\(Self.self).integerForKey", placeholder: 0),
        remove: unimplemented("\(Self.self).remove"),
        setBool: unimplemented("\(Self.self).setBool"),
        setData: unimplemented("\(Self.self).setData"),
        setString: unimplemented("\(Self.self).setString"),
        setDouble: unimplemented("\(Self.self).setDouble"),
        setInteger: unimplemented("\(Self.self).setInteger")
    )
}

extension UserDefaultsClient {
    public static let noop = Self(
        boolForKey: { _ in false },
        dataForKey: { _ in nil },
        stringForKey: { _ in nil },
        doubleForKey: { _ in 0 },
        integerForKey: { _ in 0 },
        remove: { _ in },
        setBool: { _, _ in },
        setData: { _, _ in },
        setString: { _, _ in },
        setDouble: { _, _ in },
        setInteger: { _, _ in }
    )
    public static var boolDictionary: [String: Bool] = [:]
    public mutating func override(bool: Bool, forKey key: String) {
        Self.boolDictionary[key] = bool
        boolForKey = {
            (Self.boolDictionary[$0]) ?? false
        }
        setBool = { value, key in Self.boolDictionary[key] = value }
    }

    public static var dataDictionary: [String: Data] = [:]
    public mutating func override(data: Data, forKey key: String) {
        Self.dataDictionary[key] = data
        dataForKey = { Self.dataDictionary[$0] }
    }

    public static var stringDictionary: [String: String] = [:]
    public mutating func override(string: String, forKey key: String) {
        Self.stringDictionary[key] = string
        stringForKey = { Self.stringDictionary[$0] }
    }

    public static var doubleDictionary: [String: Double] = [:]
    public mutating func override(double: Double, forKey key: String) {
        Self.doubleDictionary[key] = double
        doubleForKey = { Self.doubleDictionary[$0] ?? 0 }
    }

    public static var integerDictionary: [String: Int] = [:]
    public mutating func override(integer: Int, forKey key: String) {
        Self.integerDictionary[key] = integer
        integerForKey = { Self.integerDictionary[$0] ?? 0 }
    }

    public static func reset() {
        boolDictionary = [:]
        stringDictionary = [:]
        doubleDictionary = [:]
        integerDictionary = [:]
    }
}
