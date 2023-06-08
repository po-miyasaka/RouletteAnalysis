//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/05.
//

import SwiftUI

public extension View {
    func extend<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        transform(self)
    }
}

// これを使うとView構造がわかりづらい。WithCloseButtonを使うのがよい。
public struct ContainerWithCloseButton: ViewModifier {
    var dismissAction: () -> Void
    public init(dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
    }

    public func body(content: Content) -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    dismissAction()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(
                            width: 22,
                            height: 22
                        )

                })
                    .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 8)
            content
        }
    }
}

public struct WithCloseButton<Content: View>: View {
    var dismissAction: () -> Void
    var content: () -> Content
    public init(dismissAction: @escaping () -> Void, content: @escaping () -> Content) {
        self.dismissAction = dismissAction
        self.content = content
    }

    @ViewBuilder
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    dismissAction()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(
                            width: 22,
                            height: 22
                        )
                })
                    .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 8)
            content()
        }
    }
}
