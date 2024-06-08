//
//  CodeGenerateService.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import Foundation

class CodeGenerateService {
    
    enum StructType {
        case resp, model
        
        var name: String {
            switch self {
            case .resp:
                return "Response"
            case .model:
                return "Model"
            }
        }
    }
    
    private let tab = "    "
    
    func generateResponseCode(from jsonString: String, params: CodeGenerateParams, mainApiRespName: String) -> Result<CodeGenerateResultModel, Error> {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return .failure(NSError(domain: "Invalid JSON string", code: 0))
        }
        
        var responseClasses: [CodeFileModel] = []
        var domainModels: [CodeFileModel] = []
        var generatedStructs = Set<String>()
        
        func generateStructCode(name: String, dict: [String: Any]) -> (String, String) {
            let importCode = "import Foundation\nimport RemoteRequest\n\n"
            let structName = "\(name.capitalized)Response"
            var structCode = "class \(structName): ObjectMappable {\n"
            structCode += "\n\(tab)typealias MappableOutput = \(name.capitalized)Model\n\n"
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
                        responseClasses.append(CodeFileModel(name: "\(nestedStructName)Response", code: nestedStructCode))
                        domainModels.append(CodeFileModel(name: "\(nestedStructName)Model", code: nestedModelCode))
                        generatedStructs.insert(nestedStructName)
                    }
                    properties += "\(tab)var \(key): \(nestedStructName)Response\n"
                    propertiesModel += "\(tab)var \(key): \(nestedStructName)Model\n"
                    codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                    initParams += "\(key): \(nestedStructName)Model, "
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
                                let (nestedStructCode, nestedModelCode) = generateStructCode(name: nestedStructName, dict: elementDict)
                                responseClasses.append(CodeFileModel(name: nestedStructName, code: nestedStructCode))
                                domainModels.append(CodeFileModel(name: "nestedModelCode", code: nestedModelCode))
                                generatedStructs.insert(nestedStructName)
                            }
                            properties += "\(tab)var \(key): [\(nestedStructName)Response]\n"
                            codingKeys += "\(tab)\(tab)case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [\(nestedStructName)Response], "
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
                initModelParams += "\(tab)\(tab)\(tab)\(key): self.\(key),\n"
            }
            
            codingKeys += "\(tab)}\n"
            
            structCode += properties
            structCode += codingKeys
            structCode += "}\n\n"
          
            if !initModelParams.isEmpty {
                initModelParams = String(initModelParams.dropLast(2))  //Remove last comma
            }
            structCode += "\(tab)func createModel() -> \(name.capitalized)Model? {\n"
            structCode += "\(tab)\(tab)return \(name.capitalized)Model(\n\(initModelParams)\n\(tab)\(tab))\n"
            structCode += "\(tab)}\n"
            
            structCode += "}\n\n"
            
            if !initParams.isEmpty {
                initParams = String(initParams.dropLast(2))
            }
            
            var modelStruct = "struct \(name.capitalized)Model {\n"
            modelStruct += propertiesModel
            modelStruct += "\n\(tab)init(\(initParams)) {\n"
            modelStruct += initAssignments
            modelStruct += "\(tab)}\n"
            modelStruct += "}\n\n"
            
            return (importCode + structCode, modelStruct)
        }
        
        let (responseCode, modelCode) = generateStructCode(name: mainApiRespName, dict: jsonDict)
        print("responseCode - \(responseCode), modelCode - \(modelCode)")
        responseClasses.append(CodeFileModel(name: "\(mainApiRespName)Response", code: responseCode))
        domainModels.append(CodeFileModel(name: "\(mainApiRespName)Model", code: modelCode))
        
        let resultModel = CodeGenerateResultModel(
            responses: params.isResponseOn ? responseClasses : [],
            models: params.isModelOn ? domainModels : [],
            request: params.isRequestOn ? "request..." : nil
        )
        return .success(resultModel)
    }
}
