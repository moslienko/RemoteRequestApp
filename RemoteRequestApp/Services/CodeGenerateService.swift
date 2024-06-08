//
//  CodeGenerateService.swift
//  RemoteRequestApp
//
//  Created by Pavel Moslienko on 08.06.2024.
//

import Foundation

class CodeGenerateService {
    
    func generateResponseCode(from jsonString: String) -> Result<CodeGenerateResultModel, Error> {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return .failure(NSError(domain: "Invalid JSON string", code: 0))
        }
        
        var responseClasses: [CodeFileModel] = []
        var domainModels: [CodeFileModel] = []
        var generatedStructs = Set<String>()
        
        func generateStructCode(name: String, dict: [String: Any]) -> (String, String) {
            var swiftCode = "import Foundation\nimport RemoteRequest\n\n"
            var structName = "\(name.capitalized)Response"
            var structCode = "class \(structName): ObjectMappable {\n"
            structCode += "\n    typealias MappableOutput = \(name.capitalized)Model\n\n"
            var properties = ""
            var codingKeys = "    enum CodingKeys: String, CodingKey {\n"
            var initParams = ""
            var initModelParams = ""
            var initAssignments = ""
            
            for (key, value) in dict {
                switch value {
                case is Int:
                    properties += "    var \(key): Int\n"
                    codingKeys += "        case \(key) = \"\(key)\"\n"
                    initParams += "\(key): Int, "
                    initAssignments += "        self.\(key) = \(key)\n"
                case is String:
                    properties += "    var \(key): String\n"
                    codingKeys += "        case \(key) = \"\(key)\"\n"
                    initParams += "\(key): String, "
                    initAssignments += "        self.\(key) = \(key)\n"
                case is Double:
                    properties += "    var \(key): Double\n"
                    codingKeys += "        case \(key) = \"\(key)\"\n"
                    initParams += "\(key): Double, "
                    initAssignments += "        self.\(key) = \(key)\n"
                case is Bool:
                    properties += "    var \(key): Bool\n"
                    codingKeys += "        case \(key) = \"\(key)\"\n"
                    initParams += "\(key): Bool, "
                    initAssignments += "        self.\(key) = \(key)\n"
                case let nestedDict as [String: Any]:
                    let nestedStructName = key.capitalized
                    if !generatedStructs.contains(nestedStructName) {
                        let (nestedStructCode, nestedModelCode) = generateStructCode(name: nestedStructName, dict: nestedDict)
                        responseClasses.append(CodeFileModel(name: nestedStructName, code: nestedStructCode))
                        domainModels.append(CodeFileModel(name: nestedModelCode, code: nestedStructCode))
                        generatedStructs.insert(nestedStructName)
                    }
                    properties += "    var \(key): \(nestedStructName)Response\n"
                    codingKeys += "        case \(key) = \"\(key)\"\n"
                    initParams += "\(key): \(nestedStructName)Response, "
                    initAssignments += "        self.\(key) = \(key)\n"
                case let array as [Any]:
                    if let firstElement = array.first {
                        switch firstElement {
                        case is Int:
                            properties += "    var \(key): [Int]\n"
                            codingKeys += "        case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [Int], "
                            initAssignments += "        self.\(key) = \(key)\n"
                        case is String:
                            properties += "    var \(key): [String]\n"
                            codingKeys += "        case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [String], "
                            initAssignments += "        self.\(key) = \(key)\n"
                        case is Double:
                            properties += "    var \(key): [Double]\n"
                            codingKeys += "        case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [Double], "
                            initAssignments += "        self.\(key) = \(key)\n"
                        case is Bool:
                            properties += "    var \(key): [Bool]\n"
                            codingKeys += "        case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [Bool], "
                            initAssignments += "        self.\(key) = \(key)\n"
                        case let elementDict as [String: Any]:
                            let nestedStructName = key.capitalized
                            if !generatedStructs.contains(nestedStructName) {
                                let (nestedStructCode, nestedModelCode) = generateStructCode(name: nestedStructName, dict: elementDict)
                                responseClasses.append(CodeFileModel(name: nestedStructName, code: nestedStructCode))
                                domainModels.append(CodeFileModel(name: nestedModelCode, code: nestedStructCode))
                                generatedStructs.insert(nestedStructName)
                            }
                            properties += "    var \(key): [\(nestedStructName)Response]\n"
                            codingKeys += "        case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [\(nestedStructName)Response], "
                            initAssignments += "        self.\(key) = \(key)\n"
                        default:
                            properties += "    var \(key): [String]\n"
                            codingKeys += "        case \(key) = \"\(key)\"\n"
                            initParams += "\(key): [String], "
                            initAssignments += "        self.\(key) = \(key)\n"
                        }
                    }
                default:
                    properties += "    var \(key): String\n"
                    codingKeys += "        case \(key) = \"\(key)\"\n"
                    initParams += "\(key): String, "
                    initAssignments += "        self.\(key) = \(key)\n"
                }
                initModelParams += "\(key): self.\(key),\n"
            }
            
            codingKeys += "    }\n"
            
            structCode += properties
            structCode += codingKeys
            structCode += "}\n\n"
          
            if !initModelParams.isEmpty {
                initModelParams = String(initModelParams.dropLast(2))  //Remove last comma
            }
            structCode += "    func createModel() -> \(name.capitalized)Model? {\n"
            structCode += "        return \(name.capitalized)Model(\n\(initModelParams)\n)\n"
            structCode += "    }\n"
            
            structCode += "}\n\n"
            
            var modelStruct = "struct \(name.capitalized)Model {\n"
            modelStruct += properties
            modelStruct += "    init(\(initParams)) {\n"
            modelStruct += initAssignments
            modelStruct += "    }\n"
            modelStruct += "}\n\n"
            
            return (swiftCode + structCode, modelStruct)
        }
        
        let (responseCode, modelCode) = generateStructCode(name: "ApiResponse", dict: jsonDict)
        let modelName = "\(jsonDict.first?.key.capitalized ?? "-")Model"
        responseClasses.append(CodeFileModel(name: "1", code: responseCode))
        domainModels.append(CodeFileModel(name: modelName, code: modelCode))
        
        let resultModel = CodeGenerateResultModel(
            responses: responseClasses,
            models: domainModels,
            request: "request..."
        )
        return .success(resultModel)
    }
}
