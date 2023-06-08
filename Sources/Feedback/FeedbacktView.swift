//
//  SwiftUIView.swift
//
//
//  Created by po_miyasaka on 2023/06/04.
//

import Combine
import ComposableArchitecture
import SwiftUI
import Utility

public struct FeedbackFeature: ReducerProtocol {
    @Dependency(\.feedbackRequester) var feedbackRequester
    public struct State: Equatable {
        var addressText = ""
        var contentText = ""
        var alertMessage: String?
        var isConnecting = false
        public init() {}
    }

    public enum Action {
        case changeAddress(String)
        case changeContent(String)
        case submit
        case setAlertMessage(String?)
        case connecting
        case finishConnecting
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .changeAddress(address):
            state.addressText = address
        case let .changeContent(content):
            state.contentText = content
        case .submit:
            let content = state.contentText
            let address = state.addressText
            if state.isConnecting {
                return .none
            } else {
                return .run { send in
                    await send(.connecting)
                    let requestData = FeedbackData(content: meta + content, address: address)
                    let result = await feedbackRequester.send(requestData)
                    switch result {
                    case .success:
                        await send(.setAlertMessage("Thanks for your feedback!"))
                    case let .failure(message):
                        await send(.setAlertMessage(message))
                    }
                    await send(.finishConnecting)
                }
            }
        case let .setAlertMessage(message):
            state.alertMessage = message

        case .finishConnecting:
            state.isConnecting = false
        case .connecting:
            state.isConnecting = true
        }
        return .none
    }

    var meta: String {
        let versionNumber = Bundle.main.releaseVersionNumber
        #if os(macOS)
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            let meta = "macOS version: \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion), machineInfo: \(machineInfo())\n"
        #else
            let meta = versionNumber + "/" + UIDevice.current.systemVersion + "/" + UIDevice.current.systemName + "/"
        #endif
        return meta
    }

    func machineInfo() -> String {
        var systeminfo = utsname()
        uname(&systeminfo)
        let machine = withUnsafeBytes(of: &systeminfo.machine) { bufPtr -> String in
            let data = Data(bufPtr)
            if let lastIndex = data.lastIndex(where: { $0 != 0 }) {
                return String(data: data[0 ... lastIndex], encoding: .isoLatin1)!
            } else {
                return String(data: data, encoding: .isoLatin1)!
            }
        }
        return machine
    }
}

public struct FeedbackView: View {
    let store: StoreOf<FeedbackFeature>
    @Environment(\.dismiss) var dismiss
    public init(store: StoreOf<FeedbackFeature>) {
        self.store = store
    }

    @ViewBuilder
    public var body: some View {
        #if os(iOS)
            mainView()
        #else
            mainView().modifier(ContainerWithCloseButton { dismiss() })

        #endif
    }

    func mainView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("Mail Address (Optional)")
                    .font(.caption)
                    .foregroundColor(Color.gray),
                        content: {
                        TextField("", text: viewStore.binding(get: \.addressText, send: FeedbackFeature.Action.changeAddress))
                            .extend {
                                #if os(iOS)
                                    $0.keyboardType(UIKeyboardType.emailAddress)
                                #else
                                    $0
                                #endif
                            }

                })

                Section(
                    header: Text("Request / Bug report / Inquery").font(.caption).foregroundColor(Color.gray),
                    footer:
                    Button(action: {
                        Task.detached {
                            viewStore.send(.submit)
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Submit")
                                .foregroundColor(viewStore.contentText.isEmpty ? Color.secondary : .white)
                                .font(.body)
                                .frame(width: 200, height: 50)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                                .padding()
                            Spacer()
                        }
                        })
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewStore.contentText.isEmpty || viewStore.isConnecting)
                        .overlay {
                            if viewStore.isConnecting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle())
                            }
                        },

                    content: { TextEditor(text: viewStore.binding(get: { _ in viewStore.contentText }, send: { FeedbackFeature.Action.changeContent($0) })).frame(minHeight: 200) }
                )
            }
            .formStyle(GroupedFormStyle())
            .alert(item: viewStore.binding(get: { $0.alertMessage }, send: { message in
                FeedbackFeature.Action.setAlertMessage(message)
            }), content: { message in
                Alert(title: Text(message), message: Text(""), dismissButton: Alert.Button.default(Text("OK"), action: {
                    dismiss()
                }))
            })
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
