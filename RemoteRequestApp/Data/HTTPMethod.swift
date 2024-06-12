//
//  HTTPMethod.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 10.06.2024.
//

import Foundation

enum HTTPMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}
