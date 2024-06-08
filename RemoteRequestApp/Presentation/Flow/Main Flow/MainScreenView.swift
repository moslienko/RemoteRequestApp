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
    
    @State var mainResponseName: String = MainScreenView.responseDefaultName {
        didSet {
            if mainResponseName.isEmpty {
                mainResponseName = MainScreenView.responseDefaultName
            }
        }
    }
    @State var text: String = """
{
    "status": "success",
    "message": "Successfully message",
    "data": {
        "id": 123,
        "name": "John Doe",
        "email": "john.doe@example.com"
    }
}
"""
    @State var response: String = ""
    @State var model: String = ""
    @State var request: String = ""
    
    @State var codeGenerateResult: CodeGenerateResultModel?
    
    private static var responseDefaultName = "Api"
    
    init(model: MainScreenViewModel = MainScreenViewModel()) {
        self.viewModel = model
        self.codeGenerateParams = CodeGenerateParams()
    }
    
    var body: some View {
        HStack {
            VStack {
                TextField(LocalizedStringKey("generate.response_name"), text: $mainResponseName)
                TextEditor(text: $text)
                HStack {
                    Toggle(isOn: $codeGenerateParams.isResponseOn) {
                        Text(LocalizedStringKey("generate.response"))
                    }
                    .toggleStyle(.checkbox)
                    Toggle(isOn: $codeGenerateParams.isModelOn) {
                        Text(LocalizedStringKey("generate.model"))
                    }
                    .toggleStyle(.checkbox)
                    Toggle(isOn: $codeGenerateParams.isRequestOn) {
                        Text(LocalizedStringKey("generate.request"))
                    }
                    .toggleStyle(.checkbox)
                }
                Button(LocalizedStringKey("generate.title"), action: {
                    self.tryGenerateCode()
                })
                .buttonStyle(.borderedProminent)
                .disabled(!codeGenerateParams.isAllowGenerate)
            }
            VStack(alignment: .leading) {
                if let codeGenerateResult = self.codeGenerateResult {
                    ScrollView {
                        createCodeFilesView(data: codeGenerateResult.responses, title: LocalizedStringKey("generate.response"))
                        createCodeFilesView(data: codeGenerateResult.models, title: LocalizedStringKey("generate.model"))
                        if let request = codeGenerateResult.request {
                            createCodeTextView(code: request, name: NSLocalizedString("generate.request", comment: ""))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - UI
private extension MainScreenView {
    
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
            from: text,
            params: codeGenerateParams,
            mainApiRespName: mainResponseName
        )
        switch result {
        case let .success(data):
            self.codeGenerateResult = data
        case let .failure(failure):
            print("tryGenerateCode failure - \(failure)")
        }
    }
}

#Preview {
    MainScreenView()
}
