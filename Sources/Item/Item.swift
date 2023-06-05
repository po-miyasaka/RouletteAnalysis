//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/05/27.
//

import SwiftUI

public struct Item: Identifiable, Equatable {
    public var id: String = UUID().uuidString
    public let number: Number
    public let color: Color
    
    public init(number: Number, color: Color) {
        self.number = number
        self.color = color
    }
    
    public static func make(_ number: Number, rule: Rule = .tripleZero) -> Self {
        let item = rule.wheel.first(where: { $0.number == number })!
        return item
        
    }
    public enum Color {
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
    
    public enum Number: Int, CaseIterable {
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
            
            return "\(self.rawValue)"
        }
    }
}


public struct ItemWithOmomi: Equatable {
    public var item: Item
    public var omomi: Int
    public var candidated: Bool = false
    
    public init(item: Item, omomi: Int, candidated: Bool = false) {
        self.item = item
        self.omomi = omomi
        self.candidated = candidated
    }
}


public enum OmomiWidth: String, CaseIterable {
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
    
    public func omomiFar(from far: Int) -> Int {
        return ((offset  + 1) - far) + 5
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
    
    public var layout: [Item]{
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
        .init(number: .n0  ,color: .green),
        .init(number: .n28 ,color: .black),
        .init(number: .n9  ,color: .red),
        .init(number: .n26 ,color: .black),
        .init(number: .n30 ,color: .red),
        .init(number: .n11 ,color: .black),
        .init(number: .n7  ,color: .red),
        .init(number: .n20 ,color: .black),
        .init(number: .n32 ,color: .red),
        .init(number: .n17 ,color: .black),
        .init(number: .n5  ,color: .red),
        .init(number: .n22 ,color: .black),
        .init(number: .n34 ,color: .red),
        .init(number: .n15 ,color: .black),
        .init(number: .n3  ,color: .red),
        .init(number: .n24 ,color: .black),
        .init(number: .n36 ,color: .red),
        .init(number: .n13 ,color: .black),
        .init(number: .n1  ,color: .red),
        .init(number: .n00 ,color: .green),
        .init(number: .n27 ,color: .red),
        .init(number: .n10 ,color: .black),
        .init(number: .n25 ,color: .red),
        .init(number: .n29 ,color: .black),
        .init(number: .n12 ,color: .red),
        .init(number: .n8  ,color: .black),
        .init(number: .n19 ,color: .red),
        .init(number: .n31 ,color: .black),
        .init(number: .n18 ,color: .red),
        .init(number: .n6  ,color: .black),
        .init(number: .n21 ,color: .red),
        .init(number: .n33 ,color: .black),
        .init(number: .n16 ,color: .red),
        .init(number: .n4  ,color: .black),
        .init(number: .n23 ,color: .red),
        .init(number: .n35 ,color: .black),
        .init(number: .n14 ,color: .red),
        .init(number: .n2  ,color: .black)
    ]
    
    static var americanLayout: [Item]  {
        var sortedByNum = Rule.americanWheel.sorted(by: {
            $0.number.rawValue < $1.number.rawValue
        })
        
        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 1)
        return sortedByNum
    }
    
    static var theStarWheel: [Item]  {
        var wheel = europeanWheel
        wheel.insert(.init(number: .n00, color: .green), at: 19)
        return wheel
    }
    
    
    
    static let europeanWheel: [Item] = [
        .init(number: .n0  ,color: .green),
        .init(number: .n32 ,color: .red),
        .init(number: .n15 ,color: .black),
        .init(number: .n19 ,color: .red),
        .init(number: .n4  ,color: .black),
        .init(number: .n21 ,color: .red),
        .init(number: .n2  ,color: .black),
        .init(number: .n25 ,color: .red),
        .init(number: .n17 ,color: .black),
        .init(number: .n34 ,color: .red),
        .init(number: .n6  ,color: .black),
        .init(number: .n27 ,color: .red),
        .init(number: .n13 ,color: .black),
        .init(number: .n36 ,color: .red),
        .init(number: .n11 ,color: .black),
        .init(number: .n30 ,color: .red),
        .init(number: .n8  ,color: .black),
        .init(number: .n23 ,color: .red),
        .init(number: .n10 ,color: .black),
        .init(number: .n5  ,color: .red),
        .init(number: .n24 ,color: .black),
        .init(number: .n16 ,color: .red),
        .init(number: .n33 ,color: .black),
        .init(number: .n1  ,color: .red),
        .init(number: .n20 ,color: .black),
        .init(number: .n14 ,color: .red),
        .init(number: .n31 ,color: .black),
        .init(number: .n9  ,color: .red),
        .init(number: .n22 ,color: .black),
        .init(number: .n18 ,color: .red),
        .init(number: .n29 ,color: .black),
        .init(number: .n7  ,color: .red),
        .init(number: .n28 ,color: .black),
        .init(number: .n12 ,color: .red),
        .init(number: .n35 ,color: .black),
        .init(number: .n3  ,color: .red),
        .init(number: .n26 ,color: .black),
    ]
    
    static var europeanLayout: [Item]  {
        var sortedByNum = Rule.europeanWheel.sorted(by: {
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
    
    static var tripleZeroLayout: [Item]  {
        var sortedByNum = Rule.tripleZeroWheel.sorted(by: {
            $0.number.rawValue < $1.number.rawValue
        })
        
        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 0)
        sortedByNum.move(fromOffsets: [sortedByNum.endIndex - 1], toOffset: 2)
        return sortedByNum
    }
}


public func makeWheelData(history: [Item], omomiWidthForSelecting: OmomiWidth, omomiWidthForHistory: OmomiWidth, rule: Rule, selectedItem: Item?) -> [ItemWithOmomi] {
    let omomiedArray = calcurate(history: history, omomiWidth: omomiWidthForHistory, rule: rule, selectedItem: selectedItem)
    let wheel = rule.wheel
    let candidated = candidate(omomiWidth: omomiWidthForSelecting, rule: rule, selectedItem: selectedItem)
    return wheel.map { item in
        return .init(item: item, omomi: omomiedArray.first(where: { $0.item.number == item.number })?.omomi ?? 0, candidated: candidated.contains(where: { $0.number.str == item.number.str }))
    }
}

public func makeLayoutData(history: [Item], omomiWidthForSelecting: OmomiWidth, omomiWidthForHistory: OmomiWidth,  rule: Rule, selectedItem: Item?) -> [ItemWithOmomi] {
    let omomiedArray = calcurate(history: history, omomiWidth: omomiWidthForHistory, rule: rule, selectedItem: selectedItem)
    let layout = rule.layout
    let candidated = candidate(omomiWidth: omomiWidthForSelecting, rule: rule, selectedItem: selectedItem)
    return layout.map { item in
        return .init( item: item, omomi: omomiedArray.first(where: { $0.item.number.str == item.number.str })?.omomi ?? 0, candidated: candidated.contains(where: { $0.number.str == item.number.str }))
    }
}

private func calcurate(history: [Item], omomiWidth: OmomiWidth, rule: Rule, selectedItem: Item?) -> [ItemWithOmomi] {
    
    
    let rawData = history.flatMap { item in
        weighting(item: item, omomiWidth: omomiWidth, rule: rule, selectedItem: selectedItem)
    }
    let result: [ItemWithOmomi] = []
    let omomied = rawData.reduce(result) { result, current in
        if let i = result.firstIndex(where: {$0.item.number.str == current.item.number.str}) {
            var result = result
            result[i].omomi += current.omomi
            return result
        } else {
            return result + [current]
        }
    }
    
    return omomied
}

private func weighting(item: Item, omomiWidth: OmomiWidth, rule: Rule, selectedItem: Item?) -> [ItemWithOmomi] {
    var result: [ItemWithOmomi] = []
    let wheel = rule.wheel
    
    let i = wheel.firstIndex(where: { item.number.str == $0.number.str })!
    let lastIndex = wheel.endIndex - 1
    
    
    (0...omomiWidth.offset).forEach { rawIndex in
        var index = rawIndex
        var overNum =  lastIndex - (i + index)
        if overNum < 0 {
            index = abs(overNum) - 1
        } else {
            index = i + index
        }
        result += [.init(item: wheel[index], omomi: omomiWidth.omomiFar(from: rawIndex))]
        
        
        if rawIndex == 0 { return }
        
        index = rawIndex
        overNum =  0 + (i - index)
        if overNum < 0 {
            index = lastIndex - (abs(overNum) - 1)
        } else {
            index = i - index
        }
        result += [.init(item: wheel[index], omomi: omomiWidth.omomiFar(from: rawIndex))]
    }
    return result
}

private func candidate(omomiWidth: OmomiWidth, rule: Rule, selectedItem: Item?) -> [Item] {
    guard let selectedItem else { return [] }
    var result: [Item] = []
    let wheel = rule.wheel
    
    let i = wheel.firstIndex(where: { selectedItem.number.str == $0.number.str })!
    let lastIndex = wheel.endIndex - 1
    
    
    (0...omomiWidth.offset).forEach { rawIndex in
        var index = rawIndex
        var overNum =  lastIndex - (i + index)
        if overNum < 0 {
            index = abs(overNum) - 1
        } else {
            index = i + index
        }
        result += [wheel[index]]
        
        
        if rawIndex == 0 { return }
        
        index = rawIndex
        overNum =  0 + (i - index)
        if overNum < 0 {
            index = lastIndex - (abs(overNum) - 1)
        } else {
            index = i - index
        }
        result += [wheel[index]]
    }
    return result
}
