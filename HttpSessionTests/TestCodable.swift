//
//  TestCodable.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 2019/12/23.
//  Copyright © 2019 keisuke yamagishi. All rights reserved.
//

import Foundation

class TestCodable: Decodable {
    var status: Int?
    var UserAgent: String?
    var HttpRequest: String?
    var postParam: String?
    var auther: String?
    var autherHP: String?
    var autherGitHub: String?
}
