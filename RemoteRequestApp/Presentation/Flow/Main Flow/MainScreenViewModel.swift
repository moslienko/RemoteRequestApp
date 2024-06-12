//
//  MainScreenViewModel.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import Foundation
import Combine
import SwiftUI

public class MainScreenViewModel: ObservableObject {
    
    var generateService: CodeGenerateService
    
    init(generateService: CodeGenerateService = CodeGenerateService()) {
        self.generateService = generateService
    }
}
