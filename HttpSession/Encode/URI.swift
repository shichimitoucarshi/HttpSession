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

    public static func encode(param: [String: String]) -> Data? {
        return URI().encode(param: param).data(using: .utf8)
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

    func toUrl() throws -> URL {
        guard let url = URL(string: self) else {
            throw NSError(domain: "Invalid URL", code: -10001, userInfo: ["LocalizedSuggestion":"Incorrect URL, let's review the URL"])
        }
        return url
    }
}
// swiftlint:enable all
