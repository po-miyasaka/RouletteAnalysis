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
    public struct State: Equatable, Codable {
        var mode: Mode = .deepest
    }

    public enum Action: Equatable {
        case select(Item)
        case selectWithTap(Item)
        case change(Mode)
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .change(mode):
            state.mode = mode
        case .select:
            break
        case let .selectWithTap(item):
            return .run { send in
                await send(.change(.selectByYourself))
                await send(.select(item))
            }
        }

        return .none
    }

    public enum Mode: String, CaseIterable, Codable {
        case deepest = "Deepest"
        case lightest = "Lightest"
        case selectByYourself = "Select by yourself"

        var searchType: SearchType? {
            switch self {
            case .deepest:
                return .deepeset
            case .lightest:
                return .lightest
            default:
                return nil
            }
        }
    }
}

public struct WheelView: View {
    typealias ItemWithOmomiAndAngle = (itemWithOmomi: ItemWithOmomi, angle: Angle)
    public struct ViewState: Equatable {
        var calucuratedData: [ItemWithOmomi]
        var selectedItem: Item?
        var lastItem: Item?
        var mode: Wheel.Mode
        var omomiWidthForPrediction: OmomiWidth

        public init(calucuratedData: [ItemWithOmomi], selectedItem: Item?, lastItem: Item?, mode: Wheel.Mode, omomiWidthForPrediction: OmomiWidth) {
            self.calucuratedData = calucuratedData
            self.selectedItem = selectedItem
            self.lastItem = lastItem
            self.mode = mode
            self.omomiWidthForPrediction = omomiWidthForPrediction
        }

        var angles: [ItemWithOmomiAndAngle] {
            let minAngle = Angle(degrees: -90)
            let maxAngle = Angle(degrees: 270)
            let tickDegrees = (maxAngle.degrees - minAngle.degrees) / Double(calucuratedData.count)
            var result = [ItemWithOmomiAndAngle]()

            for tick in 0 ..< calucuratedData.count {
                let data = calucuratedData[tick]
                let angle = Angle(degrees: Double(tick) * tickDegrees)
                //            print(angle.degrees)
                result.append((data, angle))
            }

            return result
        }
    }

    @ObservedObject var viewStore: ViewStore<ViewState, Wheel.Action>

    let width: Double = 290
    public init(store: Store<ViewState, Wheel.Action>) {
        viewStore = ViewStore(store)
    }

    public var body: some View {
        let item = viewStore.mode.searchType.flatMap { viewStore.calucuratedData.searchFor(width: viewStore.omomiWidthForPrediction, searchType: $0) }

        Group {
            VStack(alignment: .center, spacing: 24) {
                ZStack(alignment: .center) {
                    let tick = (Double(360) / Double(viewStore.angles.count))
                    ForEach(Array(viewStore.angles.enumerated()), id: \.element.itemWithOmomi.item.number) { _, data in
                        rouletteNumbers(tick: tick, data: data)
                    }

                    centerCircle()

                }.frame(width: width, height: width)
                    .offset(y: -(width / 2))

                Picker("Mode", selection: viewStore.binding(get: \.mode, send: {
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
            if let item = newValue?.item, item.number != viewStore.selectedItem?.number {
                viewStore.send(.select(item))
            }
        })
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
            .foregroundColor(data.itemWithOmomi.item.color.value)
            .opacity(Double(data.itemWithOmomi.omomi) / 100.0 + 0.01)

            .rotationEffect(data.angle - Angle(degrees: Double(0.5)), anchor: UnitPoint(x: 0.5, y: 1))
            .onTapGesture {
                print(data.itemWithOmomi.item.number.str)
                viewStore.send(.selectWithTap(data.itemWithOmomi.item))
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
