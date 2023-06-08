//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import Item
import SwiftUI
public struct Wheel: ReducerProtocol {
    public struct State {}

    public enum Action: Equatable {
        case select(Item)
    }

    public func reduce(into _: inout State, action _: Action) -> ComposableArchitecture.EffectTask<Action> {
        .none
    }
}

public struct WheelView: View {
    public struct ViewState: Equatable {
        var rule: Rule
        var calucuratedData: [ItemWithOmomi]
        var selectedItem: Item?
        var lastItem: Item?

        public init(rule: Rule, calucuratedData: [ItemWithOmomi], selectedItem: Item?, lastItem: Item?) {
            self.rule = rule
            self.calucuratedData = calucuratedData
            self.selectedItem = selectedItem
            self.lastItem = lastItem
        }
    }

    @ObservedObject var viewStore: ViewStore<ViewState, Wheel.Action>
    let minAngle = Angle(degrees: -90)
    let maxAngle = Angle(degrees: 270)
    let width: Double = 290

    public init(store: Store<ViewState, Wheel.Action>) {
        viewStore = ViewStore(store)
    }

    typealias ItemWithOmomiAndAngle = (itemWithOmomi: ItemWithOmomi, angle: Angle)
    var angles: [ItemWithOmomiAndAngle] {
        let tickDegrees = (maxAngle.degrees - minAngle.degrees) / Double(viewStore.calucuratedData.count)
        var result = [ItemWithOmomiAndAngle]()

        for tick in 0 ..< viewStore.calucuratedData.count {
            let data = viewStore.calucuratedData[tick]
            let angle = Angle(degrees: Double(tick) * tickDegrees)
            //            print(angle.degrees)
            result.append((data, angle))
        }

        return result
    }

    public var body: some View {
        ZStack(alignment: .center) {
            let tick = (Double(360) / Double(angles.count))
            ForEach(Array(angles.enumerated()), id: \.element.itemWithOmomi.item.number) { _, data in
                rouletteNumbers(tick: tick, data: data)
            } // 全体が何故かずれるから調整

            centerCircle()
//            outsideCircle()
        }
        .frame(width: width, height: width)
        .offset(y: -(width / 2))

        //        .offset(y: -100)
        //        .border(.green)
    }

    @ViewBuilder
    func rouletteNumbers(tick: Double, data: ItemWithOmomiAndAngle) -> some View {
        if data.itemWithOmomi.candidated {
            Path { path in

                //                    path.addLines([CGPoint(x: width / 2, y: width / 2)])
                path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                            radius: width / 1.9, // 半径
                            startAngle: Angle(degrees: Double(-90 - (tick / 2))),
                            endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick)), // 0 is the most right
                            clockwise: false) // 時計回りかどうか なんか逆じゃね？
                //                    path.addLines([CGPoint(x: width / 2, y: width / 2)])
                path.closeSubpath()
            }.offset(y: width / 2)
                .stroke(lineWidth: 4)
                .foregroundColor(.orange)
                .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
        }
        if data.itemWithOmomi.item.number == viewStore.lastItem?.number {
            Path { path in

                //                    path.addLines([CGPoint(x: width / 2, y: width / 2)])
                path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                            radius: width / 1.8, // 半径
                            startAngle: Angle(degrees: Double(-90 - (tick / 2))),
                            endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick)), // 0 is the most right
                            clockwise: false) // 時計回りかどうか なんか逆じゃね？
                //                    path.addLines([CGPoint(x: width / 2, y: width / 2)])
                path.closeSubpath()
            }.offset(y: width / 2)
                .stroke(lineWidth: 4)
                .foregroundColor(.yellow)
                .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
        }

        Path { path in

            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 2, // 半径
                        startAngle: Angle(degrees: Double(-90 - (tick / 2)) - 0.5),
                        endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick)), // 0 is the most right
                        clockwise: false) // 時計回りかどうか なんか逆じゃね？
            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.closeSubpath()
        }.offset(y: width / 2)
            .fill()
            .foregroundColor(data.itemWithOmomi.item.color.value)
            .opacity(Double(data.itemWithOmomi.omomi) / 100.0 + 0.01)

            .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
            .onTapGesture {
                print(data.itemWithOmomi.item.number.str)
                viewStore.send(.select(data.itemWithOmomi.item))
            }

        Path { path in

            path.addLines([CGPoint(x: width / 2, y: width / 2)])
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 2, // 半径
                        startAngle: Angle(degrees: Double(-90 - (tick / 2))),
                        endAngle: Angle(degrees: Double(-90 - (tick / 2) + tick) + 0.2), // 0 is the most right
                        clockwise: false) // 時計回りかどうか なんか逆じゃね？
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
                print(data.itemWithOmomi.item.number.str)
                viewStore.send(.select(data.itemWithOmomi.item))
            }

        VStack(alignment: .center) {
            Text(
                data.itemWithOmomi.item.number.str)
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

        Path { path in
            path.addArc(center: CGPoint(x: width / 2, y: width / 2),
                        radius: width / 3, // 半径
                        startAngle: Angle(degrees: Double(0)),
                        endAngle: Angle(degrees: Double(360)), // 0 is the most right
                        clockwise: true) // 時計回りかどうか なんか逆じゃね？
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
