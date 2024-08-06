//
//  BuildData.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2022/02/04.
//

import Foundation

class BuildData {
    static func build(param: String,
                      responce: String = "",
                      result: String = "",
                      error: String = "") -> String
    {
        "param:\n\(param)\nresponce header:\n\(responce)\nresult:\n \n\(result)\n\(error)"
    }

    static func build(data: Data?,
                      parameter: [String: String],
                      responce: HTTPURLResponse?,
                      error: Error?,
                      completion: (String) -> Void)
    {
        let parameter = parameter.map {
            "\($0.key): \($0.value)\n"
        }.joined()
        if let unwrapData = data,
           let result = String(data: unwrapData, encoding: .utf8),
           let unwrapResponce = responce
        {
            let responceString = String(describing: unwrapResponce)
            let result = BuildData.build(param: parameter,
                                         responce: responceString,
                                         result: result)

            completion(result)
        } else if let unwrapResponce = responce {
            let responceString = String(describing: unwrapResponce)
            let result = BuildData.build(param: parameter, responce: responceString)

            completion(result)
        } else if let unwrapError = error {
            let errorString = String(describing: unwrapError)
            let result = BuildData.build(param: parameter, error: errorString)
            completion(result)
        }
    }
}
