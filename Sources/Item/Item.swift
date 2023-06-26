//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/27.
//

import SwiftUI

public struct Item: Identifiable, Equatable, Codable {
    
    public var id: UUID
    public let number:         Number
    public let color: Color

    public init(number: Number, color: Color, id: UUID = UUID()) {
        self.number = number
        self.color = color
        self.id = id
    }
    

    public static func make(_ number: Number, rule: Rule = .tripleZero) -> Self {
        let item = rule.wheel.first(where: { $0.number == number })!
        return item
    }

    public enum Color: Codable {
        case red
        case black
        case green
        public var value: SwiftUI.Color {
            switch self {
            case .red:
                return SwiftUI.Color.red
            case .black:
                return SwiftUI.Color.black
            case .green:
                return SwiftUI.Color.green
            }
        }
    }

    public enum Number: Int, CaseIterable, Codable {
        case n0 = 0
        case n1
        case n2
        case n3
        case n4
        case n5
        case n6
        case n7
        case n8
        case n9
        case n10
        case n11
        case n12
        case n13
        case n14
        case n15
        case n16
        case n17
        case n18
        case n19
        case n20
        case n21
        case n22
        case n23
        case n24
        case n25
        case n26
        case n27
        case n28
        case n29
        case n30
        case n31
        case n32
        case n33
        case n34
        case n35
        case n36
        case n37
        case n00
        case n000

        public var str: String {
            if case .n00 = self {
                return "00"
            }

            if case .n000 = self {
                return "000"
            }

            return "\(rawValue)"
        }
    }
}

public struct ItemWithWeight: Equatable, Codable {
    public var item: Item
    public var weight: Int
    public var candidated: Bool = false

    public init(item: Item, weight: Int, candidated: Bool = false) {
        self.item = item
        self.weight = weight
        self.candidated = candidated
    }
}

public enum WeightWidth: String, CaseIterable {
    case one
    case three
    case five
    case seven
    case nine
    case eleven
    case thirteen

    public var offset: Int {
        switch self {
        case .one:
            return 0
        case .three:
            return 1
        case .five:
            return 2
        case .seven:
            return 3
        case .nine:
            return 4
        case .eleven:
            return 5
        case .thirteen:
            return 6
        }
    }

    public var displayValue: String {
        switch self {
        case .one:
            return "1"
        case .three:
            return "3"
        case .five:
            return "5"
        case .seven:
            return "7"
        case .nine:
            return "9"
        case .eleven:
            return "11"
        case .thirteen:
            return "13"
        }
    }

    public func weightFar(from far: Int) -> Int {
        return ((offset + 1) - far) + 5
    }
}

public enum Rule: String, CaseIterable {
    case american
    case european
    case tripleZero
    case theStar

    public var displayName: String {
        switch self {
        case .theStar:
            return "The Star"
        case .american:
            return "American"
        case .european:
            return "European"
        case .tripleZero:
            return "Triple Zero"
        }
    }

    public var zeroCount: Int {
        switch self {
        case .american:
            return 2
        case .european:
            return 1
        case .tripleZero:
            return 3
        case .theStar:
            return 2
        }
    }

    public var wheel: [Item] {
        switch self {
        case .american:
            return Self.americanWheel
        case .european:
            return Self.europeanWheel
        case .tripleZero:
            return Self.tripleZeroWheel
        case .theStar:
            return Self.theStarWheel
        }
    }

    public var layout: [Item] {
        switch self {
        case .american:
            return Self.americanLayout
        case .european:
            return Self.europeanLayout
        case .tripleZero:
            return Self.tripleZeroLayout
        case .theStar:
            return Self.americanLayout
        }
    }

    static let americanWheel: [Item] = [
        .init(number: .n0, color: .green),
        .init(number: .n28, color: .black),
        .init(number: .n9, color: .red),
        .init(number: .n26, color: .black),
        .init(number: .n30, color: .red),
        .init(number: .n11, color: .black),
        .init(number: .n7, color: .red),
        .init(number: .n20, color: .black),
        .init(number: .n32, color: .red),
        .init(number: .n17, color: .black),
        .init(number: .n5, color: .red),
        .init(number: .n22, color: .black),
        .init(number: .n34, color: .red),
        .init(number: .n15, color: .black),
        .init(number: .n3, color: .red),
        .init(number: .n24, color: .black),
        .init(number: .n36, color: .red),
        .init(number: .n13, color: .black),
        .init(number: .n1, color: .red),
        .init(number: .n00, color: .green),
        .init(number: .n27, color: .red),
        .init(number: .n10, color: .black),
        .init(number: .n25, color: .red),
        .init(number: .n29, color: .black),
        .init(number: .n12, color: .red),
        .init(number: .n8, color: .black),
        .init(number: .n19, color: .red),
        .init(number: .n31, color: .black),
        .init(number: .n18, color: .red),
        .init(number: .n6, color: .black),
        .init(number: .n21, color: .red),
        .init(number: .n33, color: .black),
        .init(number: .n16, color: .red),
        .init(number: .n4, color: .black),
        .init(number: .n23, color: .red),
        .init(number: .n35, color: .black),
        .init(number: .n14, color: .red),
        .init(number: .n2, color: .black)
    ]

    static var americanLayout: [Item] {
        var sortedByNum = Rule.americanWheel.sorted(by: {
            $0.number.rawValue < $1.number.rawValue
        })

        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 1)
        return sortedByNum
    }

    static var theStarWheel: [Item] {
        var wheel = europeanWheel
        wheel.insert(.init(number: .n00, color: .green), at: 19)
        return wheel
    }

    static let europeanWheel: [Item] = [
        .init(number: .n0, color: .green),
        .init(number: .n32, color: .red),
        .init(number: .n15, color: .black),
        .init(number: .n19, color: .red),
        .init(number: .n4, color: .black),
        .init(number: .n21, color: .red),
        .init(number: .n2, color: .black),
        .init(number: .n25, color: .red),
        .init(number: .n17, color: .black),
        .init(number: .n34, color: .red),
        .init(number: .n6, color: .black),
        .init(number: .n27, color: .red),
        .init(number: .n13, color: .black),
        .init(number: .n36, color: .red),
        .init(number: .n11, color: .black),
        .init(number: .n30, color: .red),
        .init(number: .n8, color: .black),
        .init(number: .n23, color: .red),
        .init(number: .n10, color: .black),
        .init(number: .n5, color: .red),
        .init(number: .n24, color: .black),
        .init(number: .n16, color: .red),
        .init(number: .n33, color: .black),
        .init(number: .n1, color: .red),
        .init(number: .n20, color: .black),
        .init(number: .n14, color: .red),
        .init(number: .n31, color: .black),
        .init(number: .n9, color: .red),
        .init(number: .n22, color: .black),
        .init(number: .n18, color: .red),
        .init(number: .n29, color: .black),
        .init(number: .n7, color: .red),
        .init(number: .n28, color: .black),
        .init(number: .n12, color: .red),
        .init(number: .n35, color: .black),
        .init(number: .n3, color: .red),
        .init(number: .n26, color: .black)
    ]

    static var europeanLayout: [Item] {
        let sortedByNum = Rule.europeanWheel.sorted(by: {
            $0.number.rawValue < $1.number.rawValue
        })

//        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 1)
        return sortedByNum
    }

    static let tripleZeroWheel: [Item] = {
        var wheel = europeanWheel
        wheel.insert(.init(number: .n00, color: .green), at: 1)
        wheel.insert(.init(number: .n000, color: .green), at: 1)
        return wheel

    }()

    static var tripleZeroLayout: [Item] {
        var sortedByNum = Rule.tripleZeroWheel.sorted(by: {
            $0.number.rawValue < $1.number.rawValue
        })

        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 0)
        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 2)
        return sortedByNum
    }
}

public func makeWheelData(history: [Item], weightWidthForSelecting: WeightWidth, weightWidthForHistory: WeightWidth, rule: Rule, selectedItem: Item?) -> [ItemWithWeight] {
    let weightedArray = calcurate(history: history, weightWidth: weightWidthForHistory, rule: rule, selectedItem: selectedItem)
    let wheel = rule.wheel
    let candidated = candidate(weightWidth: weightWidthForSelecting, rule: rule, selectedItem: selectedItem)
    return wheel.map { item in
        .init(item: item, weight: weightedArray.first(where: { $0.item.number == item.number })?.weight ?? 0, candidated: candidated.contains(where: { $0.number.str == item.number.str }))
    }
}

public func makeLayoutData(history: [Item], weightWidthForSelecting: WeightWidth, weightWidthForHistory: WeightWidth, rule: Rule, selectedItem: Item?) -> [ItemWithWeight] {
    let weightedArray = calcurate(history: history, weightWidth: weightWidthForHistory, rule: rule, selectedItem: selectedItem)
    let layout = rule.layout
    let candidated = candidate(weightWidth: weightWidthForSelecting, rule: rule, selectedItem: selectedItem)
    return layout.map { item in
        .init(item: item, weight: weightedArray.first(where: { $0.item.number.str == item.number.str })?.weight ?? 0, candidated: candidated.contains(where: { $0.number.str == item.number.str }))
    }
}

private func calcurate(history: [Item], weightWidth: WeightWidth, rule: Rule, selectedItem: Item?) -> [ItemWithWeight] {
    let rawData = history.flatMap { item in
        weighting(item: item, weightWidth: weightWidth, rule: rule, selectedItem: selectedItem)
    }
    let result: [ItemWithWeight] = []
    let weighted = rawData.reduce(result) { result, current in
        if let i = result.firstIndex(where: { $0.item.number.str == current.item.number.str }) {
            var result = result
            result[i].weight += current.weight
            return result
        } else {
            return result + [current]
        }
    }

    return weighted
}

private func weighting(item: Item, weightWidth: WeightWidth, rule: Rule, selectedItem _: Item?) -> [ItemWithWeight] {
    let wheel = rule.wheel

    let i = wheel.firstIndex(where: { item.number.str == $0.number.str })!

    return wheel.archSlice(offset: weightWidth.offset, centerIndex: i) { item, offsetIndex -> ItemWithWeight in
        .init(item: item, weight: weightWidth.weightFar(from: offsetIndex))
    }
}

private func candidate(weightWidth: WeightWidth, rule: Rule, selectedItem: Item?) -> [Item] {
    guard let selectedItem else { return [] }
    let wheel = rule.wheel

    let i = wheel.firstIndex(where: { selectedItem.number.str == $0.number.str })!
    return wheel.archSlice(offset: weightWidth.offset, centerIndex: i) { item, _ in item }
}

public extension Array where Element == ItemWithWeight {
    func searchFor(width: WeightWidth, searchType: SearchType) -> ItemWithWeight {
        let item: ItemWithWeight?
        switch searchType {
        case .deepeset:
            item = self.max { lhs, rhs in
                lhs.weight < rhs.weight
            }
        case .lightest:
            item = self.min { lhs, rhs in
                lhs.weight < rhs.weight
            }
        }

        guard let item else { return self[0] }

        let indices: [Int] = zip(0 ..< count, self).compactMap { index, element in
            element.weight == item.weight ? index : nil
        }

        let areaItemsArray: [(index: Int, items: [ItemWithWeight])] = indices.map { i in
            (index: i, items: self.archSlice(offset: width.offset, centerIndex: i) { item, _ in item })
        }

        switch searchType {
        case .deepeset:
            let index = areaItemsArray.max(by: { $0.items.reduce(0) { $0 + $1.weight } < $1.items.reduce(0) { $0 + $1.weight } })?.index ?? 0
            return self[index]
        case .lightest:
            let index = areaItemsArray.min(by: { $0.items.reduce(0) { $0 + $1.weight } < $1.items.reduce(0) { $0 + $1.weight } })?.index ?? 0
            return self[index]
        }
    }
}

public extension Array {
    func archSlice<T>(offset: Int, centerIndex: Int, transform: (Element, Int) -> T) -> [T] {
        let lastIndex = endIndex - 1
        var archItems: [T] = []
        (0 ... offset).forEach { rawIndex in
            var index = rawIndex
            var overNum = lastIndex - (centerIndex + index)
            if overNum < 0 {
                index = abs(overNum) - 1
            } else {
                index = centerIndex + index
            }
            archItems += [transform(self[index], rawIndex)]

            if rawIndex == 0 { return }

            index = rawIndex
            overNum = 0 + (centerIndex - index)
            if overNum < 0 {
                index = lastIndex - (abs(overNum) - 1)
            } else {
                index = centerIndex - index
            }
            archItems += [transform(self[index], rawIndex)]
        }
        return archItems
    }
}

public enum SearchType {
    case deepeset
    case lightest
}
