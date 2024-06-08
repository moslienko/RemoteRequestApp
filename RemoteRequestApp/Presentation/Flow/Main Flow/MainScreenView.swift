//
//  MainScreenView.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import SwiftUI

struct MainScreenView: View {
    
    @ObservedObject var viewModel: MainScreenViewModel
    @State var text: String = ""
    
    init(model: MainScreenViewModel = MainScreenViewModel()) {
        self.viewModel = model
    }
    
    var body: some View {
        HStack {
            VStack {
                TextEditor(text: $text)
                Button(LocalizedStringKey("generate.title"), action: {
                    
                })
                .buttonStyle(.borderedProminent)
                
            }
        }
        .padding()
    }
}

#Preview {
    MainScreenView()
}
