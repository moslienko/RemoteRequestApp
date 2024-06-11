//
//  CodeGenerateResultModel.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import Foundation

struct CodeGenerateResultModel {
    var responses: [CodeFileModel]
    var models: [CodeFileModel]
    var requests: [CodeFileModel]
    var route: String?
}
