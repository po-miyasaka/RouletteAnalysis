//
//  SwiftUIView.swift
//  
//
//  Created by po_miyasaka on 2023/06/04.
//


import Combine
import SwiftUI
import ComposableArchitecture
import Utility


public struct FeedbackURL: DependencyKey {
    var url: URL?
    var urlRequest: URLRequest? {
        url.flatMap { .init(url: $0)}
    }
}

extension FeedbackURL {
    public static var liveValue: FeedbackURL = {
        guard let path = Bundle.main.path(forResource: "ProductionInfo", ofType: "plist"),
              let productionInfoDict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let requestURL = productionInfoDict["FeedbackURL"] as? String,
              let url = URL(string: requestURL) else {
            return .init(url: nil)
        }
        return .init(url: url)
    }()
}

public extension DependencyValues {
    var feedbackURL: FeedbackURL {
        get {self[FeedbackURL.self]}
        set {self[FeedbackURL.self] = newValue}
    }
}

public struct RequestFeature: ReducerProtocol {
    @Dependency(\.feedbackURL) var feedbackURL
    public struct State: Equatable {
        var addressText = ""
        var contentText = ""
        var alertMessage: String?
        public init() {}
    }
    
    public struct RequestData: Codable {
        let content: String
        let address: String
        var appName: String = "RouletteAnalysis"
    }
    
    public enum Action {
        case changeAddress(String)
        case changeContent(String)
        case submit
        case setAlertMessage(String?)
    }
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .changeAddress(let address):
            state.addressText = address
        case .changeContent(let content):
            state.contentText = content
        case .submit:
            let versionNumber = Bundle.main.releaseVersionNumber
            let content = state.contentText
            let address = state.addressText
            return .run { send in
                guard var urlRequest = feedbackURL.urlRequest else {
                    await send(.setAlertMessage("Sorry. a problem occured. (Code: 404)."))
                    return
                }
#if os(macOS)
                let osVersion = ProcessInfo.processInfo.operatingSystemVersion
                let meta = "macOS version: \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion), machineInfo: \(machineInfo())\n"
#else
                let meta = await versionNumber + "/" + UIDevice.current.systemVersion + "/" + UIDevice.current.systemName + "/"
#endif
                guard let data = try? JSONEncoder().encode(RequestData(content: meta + content, address: address)) else {
                    await send(.setAlertMessage("Sorry. a problem occured. (Code: 401)."))
                    return
                }
                urlRequest.httpBody = data
                urlRequest.httpMethod = "POST"
                
                do {
                    let (data, response) = try await URLSession.shared.data(for: urlRequest)
                    print(String(data: data, encoding: .utf8) ?? "no data")
                    print(response)
                    await send (.setAlertMessage("Thanks for your feedback!"))
                } catch {
                    await send (.setAlertMessage("Sorry. a problem occured. please try again later."))
                }
            }
            
            
        case .setAlertMessage(let message):
            state.alertMessage = message
        }
        return .none
    }
}

public struct RequestView: View {
    let store: StoreOf<RequestFeature>
    @Environment(\.dismiss) var dismiss
    public init(store: StoreOf<RequestFeature>) {
        self.store = store
    }
    
    @ViewBuilder
    public var body: some View {
        
#if os(iOS)
        mainView()
#else
        mainView().modifier(ContainerWithCloseButton{ dismiss() })
        
#endif
        
    }
    
    func mainView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("Mail Address (Optional)").font(.caption).foregroundColor(Color.gray), content: {
                    
                    TextField("", text: viewStore.binding(get: \.addressText,send: RequestFeature.Action.changeAddress )).extend {
#if os(iOS)
                        $0.keyboardType(UIKeyboardType.emailAddress)
#else
                        $0
#endif
                    }
                    
                })
                
                
                Section(
                    header: Text("Request / Bug report / Inquery").font(.caption).foregroundColor(Color.gray) ,
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
                        .disabled(viewStore.contentText.isEmpty)
                    
                    ,
                    content: { TextEditor(text: viewStore.binding(get: {_ in viewStore.contentText}, send: {RequestFeature.Action.changeContent($0)})).frame(minHeight: 200) }
                )
                
                
            }
            .formStyle(GroupedFormStyle())
            .alert(item: viewStore.binding(get: {  $0.alertMessage }, send: { message in
                RequestFeature.Action.setAlertMessage(message)
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

func machineInfo() -> String {
    var systeminfo = utsname()
    uname(&systeminfo)
    let machine = withUnsafeBytes(of: &systeminfo.machine) { bufPtr -> String in
        let data = Data(bufPtr)
        if let lastIndex = data.lastIndex(where: {$0 != 0}) {
            return String(data: data[0...lastIndex], encoding: .isoLatin1)!
        } else {
            return String(data: data, encoding: .isoLatin1)!
        }
    }
    return machine
}

