//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import Item
import Roulette
import Setting
import SwiftUI
import Utility
import Wheel

public struct WheelView: View {
    typealias ItemWithWeightAndAngle = (itemWithWeight: ItemWithWeight, angle: Angle)

    @ObservedObject var rouletteViewStore: ViewStoreOf<Roulette>
    @ObservedObject var settingViewStore: ViewStoreOf<Setting>
    @ObservedObject var wheelViewStore: ViewStoreOf<Wheel>

    let rouletteStore: StoreOf<Roulette>
    let settingStore: StoreOf<Setting>

    public init(
        rouletteStore: StoreOf<Roulette>,
        settingStore: StoreOf<Setting>
    ) {
        rouletteViewStore = ViewStore(rouletteStore)
        settingViewStore = ViewStore(settingStore)
        self.rouletteStore = rouletteStore
        self.settingStore = settingStore
        wheelViewStore = ViewStore(rouletteStore.wheelStore)
    }

    let width: Double = 290

    func angles(culucuratedData: [ItemWithWeight]) -> [ItemWithWeightAndAngle] {
        let minAngle = Angle(degrees: -90)
        let maxAngle = Angle(degrees: 270)
        let tickDegrees = (maxAngle.degrees - minAngle.degrees) / Double(culucuratedData.count)
        var result = [ItemWithWeightAndAngle]()

        for tick in 0 ..< culucuratedData.count {
            let data = culucuratedData[tick]
            let angle = Angle(degrees: Double(tick) * tickDegrees)
            //            print(angle.degrees)
            result.append((data, angle))
        }
        return result
    }

    public var body: some View {
        let calucuratedData = wheelData(roulette: rouletteViewStore.state, setting: settingViewStore.state)
        let angles = angles(culucuratedData: calucuratedData)
        let item = wheelViewStore.mode.searchType.flatMap { calucuratedData.searchFor(width: settingViewStore.weightWidthForPrediction, searchType: $0) }

        Group {
            VStack(alignment: .center, spacing: 24) {
                ZStack(alignment: .center) {
                    let tick = (Double(360) / Double(angles.count))
                    ForEach(Array(angles.enumerated()), id: \.element.itemWithWeight.item.number) { _, data in
                        rouletteNumbers(tick: tick, data: data)
                    }

                    centerCircle()

                }.frame(width: width, height: width)
                    .offset(y: -(width / 2))

                Picker("Mode", selection: wheelViewStore.binding(get: \.mode, send: {
                    Wheel.Action.change($0)
                })) {
                    ForEach(Wheel.Mode.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
        }
        .onChange(of: item, perform: { newValue in
            // TCA doesn't allow knowing changes of states and sending action after a state changed, so doing it here.
            if let item = newValue?.item, item.number != rouletteViewStore.selectedForPrediction?.number {
                wheelViewStore.send(.select(item))
            }
        })
    }

    @ViewBuilder
    func rouletteNumbers(tick: Double, data: ItemWithWeightAndAngle) -> some View {
        if data.itemWithWeight.candidated {
            Path { path in

                //                    path.addLines([CGPoint(x: width / 2, y: width / 2)])
                path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                            radius: width / 1.9, // 半径
                            startAngle: Angle(degrees: Double(-90 - (tick / 2))),
                            endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick)), // 0 is the most right
                            clockwise: false) // 時計回りかどうか なんか逆じゃね？
                path.closeSubpath()
            }.offset(y: width / 2)
                .stroke(lineWidth: 4)
                .foregroundColor(.orange)
                .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
        }
        if data.itemWithWeight.item.number == rouletteViewStore.history.limitedHistory.last?.item.number {
            Path { path in

                //                    path.addLines([CGPoint(x: width / 2, y: width / 2)])
                path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                            radius: width / 1.8, // 半径
                            startAngle: Angle(degrees: Double(-90 - (tick / 2))),
                            endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick)), // 0 is the most right
                            clockwise: false)
                path.closeSubpath()
            }.offset(y: width / 2)
                .stroke(lineWidth: 4)
                .foregroundColor(.yellow)
                .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
        }

        Path { path in

            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 2,
                        startAngle: Angle(degrees: Double(-90 - (tick / 2)) - 0.5),
                        endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick)),
                        clockwise: false)
            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.closeSubpath()
        }.offset(y: width / 2)
            .fill()
            .foregroundColor(data.itemWithWeight.item.color.value)
            .opacity(Double(data.itemWithWeight.weight) / 100.0 + 0.01)

            .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
            .onTapGesture {
                print(data.itemWithWeight.item.number.str)
                wheelViewStore.send(.selectWithTap(data.itemWithWeight.item))
            }

        Path { path in

            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 2,
                        startAngle: Angle(degrees: Double(-90 - (tick / 2))),
                        endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick) + 0.2),
                        clockwise: false)
            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.closeSubpath()
        }.offset(y: width / 2)
            .stroke(lineWidth: 1)
            .extend {
                #if os(macOS)
                    $0.foregroundColor(Color(nsColor: .separatorColor))
                #else
                    $0.foregroundColor(Color(uiColor: .separator))
                #endif
            }
            .rotationEffect(data.angle - Angle(degrees: Double(1)), anchor: UnitPoint(x: 0.5, y: 1))
            .onTapGesture {
                print(data.itemWithWeight.item.number.str)
                wheelViewStore.send(.select(data.itemWithWeight.item))
            }

        VStack(alignment: .center) {
            Text(
                data.itemWithWeight.item.number.str)
                .frame(alignment: .center)
                .font(.caption)
                .foregroundColor(.black)
                .bold()
                .offset(y: -(width / 2) + 18)
                .rotationEffect(Angle(degrees: data.angle.degrees - 1), anchor: UnitPoint(x: 0.5, y: 1))
                .offset(y: (width / 2) - 6)
        }
    }

    @ViewBuilder
    func outsideCircle() -> some View {
        Path { path in
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 2, // 半径
                        startAngle: Angle(degrees: Double(0)),
                        endAngle: Angle(degrees: Double(360)), // 0 is the most right
                        clockwise: true) // 時計回りかどうか なんか逆じゃね？
        }
        .offset(y: width / 2)
        .stroke(lineWidth: 1)
        .extend {
            #if os(macOS)
                $0.foregroundColor(Color(nsColor: .separatorColor))
            #else
                $0.foregroundColor(Color(uiColor: .separator))
            #endif
        }
    }

    @ViewBuilder
    func centerCircle() -> some View {
        Path { path in
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 3, // 半径
                        startAngle: Angle(degrees: Double(0)),
                        endAngle: Angle(degrees: Double(360)), // 0 is the most right
                        clockwise: true)
        }
        .offset(y: width / 2)
        .stroke(lineWidth: 1)
        .extend {
            #if os(macOS)
                $0.foregroundColor(Color(nsColor: .separatorColor))
            #else
                $0.foregroundColor(Color(uiColor: .separator))
            #endif
        }

        Path { path in
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 3, // 半径
                        startAngle: Angle(degrees: Double(0)),
                        endAngle: Angle(degrees: Double(360)), // 0 is the most right
                        clockwise: true)
        }
        .offset(y: width / 2)
        .fill()
        .foregroundColor(.white)
    }
}

extension Angle: Identifiable {
    public var id: Double {
        radians
    }
}

public func wheelData(roulette: Roulette.State, setting: Setting.State) -> [ItemWithWeight] {
    makeWheelData(history: roulette.history.limitedHistory.map(\.item),
                  weightWidthForSelecting: setting.weightWidthForPrediction,
                  weightWidthForHistory: setting.weightWidthForHistory,
                  rule: setting.rule,
                  selectedItem: roulette.selectedForPrediction)
}
