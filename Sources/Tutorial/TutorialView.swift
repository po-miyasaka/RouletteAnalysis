//
//  SwiftUIView.swift
//
//
//  Created by po_miyasaka on 2023/06/03.
//

import SwiftUI
import Utility

public struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    public init() {}
    public var body: some View {
        #if os(macOS)
            ScrollView {
                form()
            }
        #else
            form()
        #endif
    }

    func form() -> some View {
        Form {
            Section("What's this app") {
                Text("This app helps you analyse roulette history and predict the next number.")
            }

            Section("The layout") {
                Image("layout", bundle: Bundle.module).resizable().aspectRatio(contentMode: .fit).frame(width: 250)
                Text(
                    """
                    You can add a number to the history by double-tapping on a number.
                    If you make a mistake, you can remove the last number by tapping the trash button at the top right of the screen.

                    The more times a number is entered, the deeper the colour of the cell.
                    Orange cells are selected in the wheel mentioned in the following section.
                    """
                )
            }

            Section("The Wheel") {
                Image("wheel", bundle: Bundle.module).resizable().aspectRatio(contentMode: .fit).frame(width: 250)
                Text(
                    """

                    This is the Roulette wheel.
                    The more times a number is hit and added to the history, the deeper the colour of the cells.
                    When a number is added, the numbers around it become deeper.
                    You can set how many cells are affected by using the Settings view.

                    You can tap the number you think will be the next number.
                    You can also set how many cells will be selected centred on the selected number.
                    """
                )
            }

            Section("The History") {
                Image("history", bundle: Bundle.module).resizable().aspectRatio(contentMode: .fit).frame(width: 250)
                Text(
                    """
                    You can set how much history can affect the layout and the wheel to predict the next number with the slider.
                    The red border appears when the prediction hits the next number.
                    """
                )
            }
        }.extend {
            #if os(macOS)
                $0.modifier(ContainerWithCloseButton { dismiss() })
            #else
                $0
            #endif
        }
    }
}
