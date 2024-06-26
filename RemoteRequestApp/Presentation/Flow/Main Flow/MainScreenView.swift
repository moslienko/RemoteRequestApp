//
//  MainScreenView.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import SwiftUI

struct MainScreenView: View {
    
    @ObservedObject var viewModel: MainScreenViewModel
    @ObservedObject var codeGenerateParams: CodeGenerateParams

    @State var codeGenerateResult: CodeGenerateResultModel?
    @State var error: Error?

    init(model: MainScreenViewModel = MainScreenViewModel()) {
        self.viewModel = model
        self.codeGenerateParams = CodeGenerateParams()
    }
    
    var body: some View {
        HStack {
            createFormView()
            VStack(alignment: .leading) {
                createCodeGenerateView()
            }
        }
        .padding()
    }
}

// MARK: - UI
private extension MainScreenView {
    
    @ViewBuilder
    func createFormView() -> some View {
        VStack {
            if codeGenerateParams.isRouteOn {
                HStack {
                    Picker(selection: $codeGenerateParams.method) {
                        ForEach(HTTPMethod.allCases, id:\.self ) { i in
                            Text(i.rawValue)
                        }
                    } label: { }
                        .frame(width: 84)
                    TextField(LocalizedStringKey("generate.url"), text: $codeGenerateParams.url)
                }
            }
            TextField(LocalizedStringKey("generate.response_name"), text: $codeGenerateParams.mainResponseName)
            TextEditor(text: $codeGenerateParams.jsonText)
            VStack(alignment: .leading) {
                HStack {
                    Toggle(isOn: $codeGenerateParams.isResponseOn) {
                        Text(LocalizedStringKey("generate.response"))
                    }
                    .toggleStyle(.checkbox)
                    Toggle(isOn: $codeGenerateParams.isModelOn) {
                        Text(LocalizedStringKey("generate.model"))
                    }
                    .toggleStyle(.checkbox)
                }
                HStack {
                    Toggle(isOn: $codeGenerateParams.isRequestOn) {
                        Text(LocalizedStringKey("generate.request_body"))
                    }
                    .toggleStyle(.checkbox)
                    Toggle(isOn: $codeGenerateParams.isRouteOn) {
                        Text(LocalizedStringKey("generate.route"))
                    }
                    .toggleStyle(.checkbox)
                }
            }
            Button(LocalizedStringKey("generate.title"), action: {
                self.tryGenerateCode()
            })
            .buttonStyle(.borderedProminent)
            .disabled(!codeGenerateParams.isAllowGenerate)
        }
    }
    
    @ViewBuilder
    func createCodeGenerateView() -> some View {
        if let error = self.error {
            Text(verbatim: error.localizedDescription)
                .font(.callout)
            Spacer()
        }
        if let codeGenerateResult = self.codeGenerateResult {
            ScrollView {
                createCodeFilesView(data: codeGenerateResult.responses, title: LocalizedStringKey("generate.response"))
                createCodeFilesView(data: codeGenerateResult.models, title: LocalizedStringKey("generate.model"))
                createCodeFilesView(data: codeGenerateResult.requests, title: LocalizedStringKey("generate.request_body"))
                if let route = codeGenerateResult.route {
                    createCodeTextView(code: route, name: NSLocalizedString("generate.route", comment: ""))
                }
            }
        }
    }
    
    @ViewBuilder
    func createCodeFilesView(data: [CodeFileModel], title: LocalizedStringKey) -> some View {
        if !data.isEmpty {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    let response = data.map({ $0.code }).joined(separator: "\n")
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(response, forType: .string)
                } label: {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text(LocalizedStringKey("generate.copyAll"))
                    }
                }
                .buttonStyle(.bordered)
            }
            ForEach(data, id: \.name) { code in
                createCodeTextView(code: code.code, name: code.name)
            }
        }
    }
    
    @ViewBuilder
    func createCodeTextView(code: String, name: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Button {
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(code, forType: .string)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)
            }
            TextEditor(text: .constant(code))
                .frame(minHeight: 50)
        }
    }
}

// MARK: - Actions
private extension MainScreenView {
    
    func tryGenerateCode() {
        let result = viewModel.generateService.generateResponseCode(
            params: codeGenerateParams
        )
        switch result {
        case let .success(data):
            self.error = nil
            self.codeGenerateResult = data
        case let .failure(error):
            print("tryGenerateCode failure - \(error)")
            self.error = error
            self.codeGenerateResult = nil
        }
    }
}

#Preview {
    MainScreenView()
}
