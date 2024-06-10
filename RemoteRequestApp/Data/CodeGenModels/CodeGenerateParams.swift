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
    @Published var isRequestOn = false
    @Published var isRouteOn = false

    @Published var mainResponseName: String = "Api"
    @Published var url: String = "/"
    @Published var jsonText: String = """
{
    "status": "success",
    "message": "Successfully message",
    "data": {
        "id": 123,
        "name": "John Doe",
        "email": "john.doe@example.com"
    },
    "user": {
        "id": 123
    }
}
"""
    @Published var method: HTTPMethod = .get
    
    var isAllowGenerate: Bool {
        isResponseOn || isModelOn || isRequestOn || isRouteOn
    }
}
