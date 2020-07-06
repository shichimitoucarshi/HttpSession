//
//  CreateMultipart.swift
//  RNTApps
//
//  Created by shichimi on 2017/05/04.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

open class Multipart {

    public struct data {
        public var fileName: String!
        public var mimeType: String!
        public var data: Data!
        public init() {
            self.fileName = ""
            self.mimeType = ""
            self.data = Data()
        }
    }

    public var bundary: String
    public var uuid: String

    public init() {
        self.uuid = UUID().uuidString
        self.bundary = String(format: "----\(self.uuid)")
    }

    public func multiparts(params: [String: Multipart.data]) -> Data {

        var post: Data = Data()

        for(key, value) in params {
            let dto: Multipart.data = value
            post.append(multipart(key: key, fileName: dto.fileName as String, mineType: dto.mimeType, data: dto.data))
        }
        return post
    }

    public func multipart(key: String, fileName: String, mineType: String, data: Data) -> Data {

        var body = Data()
        let CRLF = "\r\n"
        body.append(("--\(self.bundary)" + CRLF).data(using: .utf8)!)
        body.append(("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"" + CRLF).data(using: .utf8)!)
        body.append(("Content-Type: \(mineType)" + CRLF + CRLF).data(using: .utf8)!)
        body.append(data)
        body.append(CRLF.data(using: .utf8)!)
        body.append(("--\(self.bundary)--" + CRLF).data(using: .utf8)!)

        return body
    }
}
