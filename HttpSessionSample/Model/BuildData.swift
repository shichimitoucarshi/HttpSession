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
}
