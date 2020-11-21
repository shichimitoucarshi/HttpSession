//
//  TestCodable.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 2019/12/23.
//  Copyright © 2019 keisuke yamagishi. All rights reserved.
//

import Foundation

class TestCodable: Decodable {
    let status: Int?
    let userAgent: String?
    let httpRequest: String?
    let postParam: String?
    let auther: String?
    let autherHP: String?
    let autherGitHub: String?

    enum CodingKeys: String, CodingKey {
        case status: Int?
        case userAgent: String? = "UserAgent"
        case HttpRequest: String? = "HttpRequest"
        case postParam: String?
        case auther: String?
        case autherHP: String?
        case autherGitHub
    }
}
