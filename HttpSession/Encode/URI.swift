//
//  URLEncode.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/17.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
// swiftlint:disable all
class URI: NSObject {

    public static func encode(param: [String: String]) -> String {
        return URI().encode(param: param)
    }

    public func encode(param: [String: String]) -> String {
        return param.map {"\($0)=\($1.percentEncode())"}.joined(separator: "&")
    }
}

extension String {

    /*
     * PersentEncode
     */
    public func percentEncode(_ encodeAll: Bool = false) -> String {
        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        if !encodeAll {
            allowedCharacterSet.insert(charactersIn: "[]")
        }
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
}
// swiftlint:enable all
