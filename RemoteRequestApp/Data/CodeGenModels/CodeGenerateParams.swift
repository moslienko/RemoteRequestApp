//
//  CodeGenerateParams.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import Foundation
import SwiftUI

class CodeGenerateParams: ObservableObject {
    @Published var isResponseOn = true
    @Published var isModelOn = true
    @Published var isRequestOn = true
    
    var isAllowGenerate: Bool {
        isResponseOn || isModelOn || isRequestOn
    }
}
