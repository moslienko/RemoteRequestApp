//
//  CodeGenerateService.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import Foundation

final class CodeGenerateService {
    
    enum StructType {
        case response, model, request
        
        var name: String {
            switch self {
            case .response:
                return "Response"
            case .model:
                return "Model"
            case .request:
                return "Request"
            }
        }
    }
    
    private let tab = "    "
    
    func generateResponseCode(params: CodeGenerateParams) -> Result<CodeGenerateResultModel, Error> {
        guard let jsonData = params.jsonText.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return .failure(NSError(domain: "Invalid JSON string", code: 0))
        }
        
        var responseClasses: [CodeFileModel] = []
        var domainModels: [CodeFileModel] = []
        var requestModels: [CodeFileModel] = []
        
        var generatedStructs = Set<String>()
        
        func generateStructCode(name: String, dict: [String: Any]) -> (String, String) {
            let importCode = "import Foundation\nimport RemoteRequest\n\n"
            let structName = "\(name.capitalized)\(StructType.response.name)"
            var structCode = "class \(structName): ObjectMappable {\n"
            
            structCode += "\n\(tab)typealias MappableOutput = \(name.capitalized)\(StructType.model.name)\n\n"
            var properties = ""
            var propertiesModel = ""
            var codingKeys = "\n\(tab)enum CodingKeys: String, CodingKey {\n"
            var initParams = ""
            var initModelParams = ""
            var initAssignments = ""
            
            for (key, value) in dict {
                switch value {
                case is Int:
                    properties += "\(tab)var \(key): Int\n"
                    propertiesModel += "\(tab)var \(key): Int\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): Int, "
                    initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                case is String:
                    properties += "\(tab)var \(key): String\n"
                    propertiesModel += "\(tab)var \(key): String\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): String, "
                    initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                case is Double:
                    properties += "\(tab)var \(key): Double\n"
                    propertiesModel += "\(tab)var \(key): Double\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): Double, "
                    initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                case is Bool:
                    properties += "\(tab)var \(key): Bool\n"
                    propertiesModel += "\(tab)var \(key): Bool\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): Bool, "
                    initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                case let nestedDict as [String: Any]:
                    let nestedStructName = key.capitalized
                    if !generatedStructs.contains(nestedStructName) {
                        let (nestedStructCode, nestedModelCode) = generateStructCode(name: nestedStructName, dict: nestedDict)
                        responseClasses.append(CodeFileModel(name: "\(nestedStructName)\(StructType.response.name)", code: nestedStructCode))
                        domainModels.append(CodeFileModel(name: "\(nestedStructName)\(StructType.model.name)", code: nestedModelCode))
                        generatedStructs.insert(nestedStructName)
                    }
                    properties += "\(tab)var \(key): \(nestedStructName)\(StructType.response.name)\n"
                    propertiesModel += "\(tab)var \(key): \(nestedStructName)\(StructType.model.name)\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): \(nestedStructName)\(StructType.model.name), "
                    initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                case let array as [Any]:
                    if let firstElement = array.first {
                        switch firstElement {
                        case is Int:
                            properties += "\(tab)var \(key): [Int]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [Int], "
                            initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                        case is String:
                            properties += "\(tab)var \(key): [String]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [String], "
                            initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                        case is Double:
                            properties += "\(tab)var \(key): [Double]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [Double], "
                            initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                        case is Bool:
                            properties += "\(tab)var \(key): [Bool]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [Bool], "
                            initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                        case let elementDict as [String: Any]:
                            let nestedStructName = key.capitalized
                            if !generatedStructs.contains(nestedStructName) {
                                let (nestedStructCode, _) = generateStructCode(name: nestedStructName, dict: elementDict)
                                responseClasses.append(CodeFileModel(name: nestedStructName, code: nestedStructCode))
                                generatedStructs.insert(nestedStructName)
                            }
                            properties += "\(tab)var \(key): [\(nestedStructName)\(StructType.response.name)]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [\(nestedStructName)\(StructType.response.name)], "
                            initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                        default:
                            properties += "\(tab)var \(key): [String]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [String], "
                            initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                        }
                    }
                default:
                    properties += "\(tab)var \(key): String\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): String, "
                    initAssignments += "\(tab)\(tab)self.\(key) = \(key)\n"
                }
            }
            
            codingKeys += "\(tab)}\n"
            
            structCode += properties
            structCode += codingKeys
            structCode += "}\n\n"
            
            var guardStatements = ""
            let respModels = dict.filter({ $0.value is [String: Any] })
            let simpleModels = dict.filter({ !($0.value is [String: Any]) })
            
            if !respModels.isEmpty {
                guardStatements += "\(tab)\(tab)guard\n"
                
                respModels.enumerated().forEach({ (index, data) in
                    let key = data.0
                    let isLast = index == respModels.count - 1
                    
                    guardStatements += "\(tab)\(tab) let \(key) = self.\(key).createModel()\(isLast ? "" : ",")\n"
                    if isLast {
                        guardStatements += "else {\n"
                        guardStatements += "\(tab)\(tab)return nil\n"
                        guardStatements += "\(tab)\(tab)}\n\n"
                    }
                    
                    initModelParams += "\(tab)\(tab)\(tab)\(key): \(key),\n"
                })
            }
            
            simpleModels.forEach({ (key, value) in
                initModelParams += "\(tab)\(tab)\(tab)\(key): self.\(key),\n"
            })
            
            if !initModelParams.isEmpty {
                initModelParams = String(initModelParams.dropLast(2))  //Remove last comma
            }
            
            structCode += "\(tab)func createModel() -> \(name.capitalized)\(StructType.model.name)? {\n\(guardStatements)"
            structCode += "\(tab)\(tab)return \(name.capitalized)\(StructType.model.name)(\n\(initModelParams)\n\(tab)\(tab))\n"
            structCode += "\(tab)}\n"
            
            structCode += "}\n\n"
            
            if !initParams.isEmpty {
                initParams = String(initParams.dropLast(2))
            }
            
            var modelStruct = "struct \(name.capitalized)\(StructType.model.name) {\n"
            modelStruct += propertiesModel
            modelStruct += "\n\(tab)init(\(initParams)) {\n"
            modelStruct += initAssignments
            modelStruct += "\(tab)}\n"
            modelStruct += "}\n\n"
            
            return (importCode + structCode, modelStruct)
        }
        
        func generateRequestCode(name: String, dict: [String: Any]) -> String {
            let importCode = "import Foundation\nimport RemoteRequest\n\n"
            let requestName = "\(name)"
            var requestCode = "struct \(requestName): InputBodyObject {\n"
            
            var properties = ""
            var propertiesModel = ""
            var codingKeys = "\n\(tab)enum CodingKeys: String, CodingKey {\n"
            
            for (key, value) in dict {
                switch value {
                case is Int:
                    properties += "\(tab)var \(key): Int\n"
                    propertiesModel += "\(tab)var \(key): Int\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                case is String:
                    properties += "\(tab)var \(key): String\n"
                    propertiesModel += "\(tab)var \(key): String\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                case is Double:
                    properties += "\(tab)var \(key): Double\n"
                    propertiesModel += "\(tab)var \(key): Double\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                case is Bool:
                    properties += "\(tab)var \(key): Bool\n"
                    propertiesModel += "\(tab)var \(key): Bool\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                case let nestedDict as [String: Any]:
                    let nestedStructName = key.capitalized + StructType.request.name
                    
                    if !generatedStructs.contains(nestedStructName) {
                        let nestedStructCode = generateRequestCode(name: nestedStructName, dict: nestedDict)
                        requestModels.append(CodeFileModel(name: "\(nestedStructName)\(StructType.request.name)", code: nestedStructCode))
                        generatedStructs.insert(nestedStructName)
                    }
                    properties += "\(tab)var \(key): \(nestedStructName)\n"
                    propertiesModel += "\(tab)var \(key): \(nestedStructName)\(StructType.model.name)\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                case let array as [Any]:
                    if let firstElement = array.first {
                        switch firstElement {
                        case is Int:
                            properties += "\(tab)var \(key): [Int]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                        case is String:
                            properties += "\(tab)var \(key): [String]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                        case is Double:
                            properties += "\(tab)var \(key): [Double]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                        case is Bool:
                            properties += "\(tab)var \(key): [Bool]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                        case let elementDict as [String: Any]:
                            let nestedStructName = key.capitalized + StructType.request.name
                            if !generatedStructs.contains(nestedStructName) {
                                let nestedStructCode = generateRequestCode(name: nestedStructName, dict: elementDict)
                                requestModels.append(CodeFileModel(name: nestedStructName, code: nestedStructCode))
                                generatedStructs.insert(nestedStructName)
                            }
                            properties += "\(tab)var \(key): [\(nestedStructName)]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                        default:
                            properties += "\(tab)var \(key): [String]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                        }
                    }
                default:
                    properties += "\(tab)var \(key): String\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                }
            }
            
            codingKeys += "\(tab)}\n"
            
            requestCode += properties
            requestCode += codingKeys
            requestCode += "}\n\n"
            
            return importCode + requestCode
        }
        let (responseCode, modelCode) = generateStructCode(name: params.mainResponseName, dict: jsonDict)
        responseClasses.append(CodeFileModel(name: "\(params.mainResponseName)\(StructType.response.name)", code: responseCode))
        domainModels.append(CodeFileModel(name: "\(params.mainResponseName)\(StructType.model.name)", code: modelCode))
        
        let requestCode = generateRequestCode(name: "\(params.mainResponseName)\(StructType.request.name)", dict: jsonDict)
        requestModels.append(CodeFileModel(name: "\(params.mainResponseName)", code: requestCode))
        
        let routeCode = generateRoute(
            method: params.method,
            url: params.url,
            modelName: params.mainResponseName
        )
        
        let resultModel = CodeGenerateResultModel(
            responses: params.isResponseOn ? responseClasses : [],
            models: params.isModelOn ? domainModels : [],
            requests: params.isRequestOn ? requestModels : [],
            route: params.isRouteOn ? routeCode : nil
        )
        return .success(resultModel)
    }
    
    func generateRoute(method: HTTPMethod, url: String, modelName: String) -> String {
        var pathURL: String {
            if url.isEmpty {
                return "/"
            }
            return url
        }
        
        let importCode = "import Foundation\nimport RemoteRequest\n\n"
        var structCode = "struct Routes {\n\(tab)private static var baseURL = \"/\"\n\n"
        // @Route
        structCode += """
    \(tab)// Select one of the methods\n
    \(tab)func fetchItems(completion: @escaping (ResultData<[\(modelName)\(StructType.model.name)]>) -> Void) {
    \(tab)\(tab)@Route<[\(modelName)\(StructType.response.name)], [\(modelName)\(StructType.model.name)], RegRestErrorResponse>(Routes.baseURL + "\(url)", method: .\(method.rawValue.lowercased()))"
    \(tab)\(tab)var request: URLRequest
    \(tab)\(tab)_request.runRequest(completion: completion)
    \(tab)}\n\n
    """
        // @Method
        structCode += """
    \(tab)func fetchItems(completion: @escaping (ResultData<[\(modelName)\(StructType.model.name)]>) -> Void) {
    \(tab)\(tab)@\(method.rawValue.uppercased())<[\(modelName)\(StructType.response.name)], [\(modelName)\(StructType.model.name)], RegRestErrorResponse>(Routes.baseURL + "\(url)")
    \(tab)\(tab)var request: RouteRestProtocol
    \(tab)\(tab)request.runRequest(completion: completion)
    \(tab)}\n\n
    """
        // Async/await
        structCode += """
    \(tab)@available(iOS 15.0, *)
    \(tab)func fetchItemsAwait() async throws -> Result<[\(modelName)\(StructType.model.name)], Error> {
    \(tab)\(tab)@Route<[\(modelName)\(StructType.response.name)], [\(modelName)\(StructType.model.name)], RegRestErrorResponse>(Routes.baseURL + "\(url)", method: .\(method.rawValue.lowercased()))"
    \(tab)\(tab)var request: URLRequest
    \(tab)\(tab)return try await _request.runRequest()
    \(tab)}\n\n
    """
        
        return importCode + structCode
    }
}
