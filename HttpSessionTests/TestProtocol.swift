//
//  TestProtocol.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 2019/12/23.
//  Copyright © 2019 keisuke yamagishi. All rights reserved.
//

import Foundation
import HttpSession
import XCTest

let TestUrl: String = "https://sevens-api.herokuapp.com"

enum TestApi {
    case test1
    case test2
    case test3
}

extension TestApi: ApiProtocol {
    var encode: Http.Encode {
        .url
    }

    var isNeedDefaultHeader: Bool {
        true
    }

    var domain: String {
        TestUrl
    }

    var endPoint: String {
        switch self {
        case .test1, .test2:
            return "postApi.json"
        case .test3:
            return "imageUp.json"
        }
    }

    var method: Http.Method {
        .post
    }

    var header: [String: String]? {
        nil
    }

    var params: [String: String]? {
        switch self {
        case .test1:
            return ["http_post": "TEST1"]
        case .test2:
            return ["http_post": "TEST2"]
        case .test3:
            return nil
        }
    }

    var multipart: [Multipartible]? {
        switch self {
        case .test1, .test2:
            return nil
        case .test3:
            guard let image: String = Bundle.main.path(forResource: "Hello", ofType: "txt") else { return nil }
            var img = Data()
            do {
                img = try Data(contentsOf: URL(fileURLWithPath: image))
            } catch {
                XCTFail()
            }
            return [Multipartible(key: "img",
                                  fileName: "Hello.txt",
                                  mineType: "text/plain",
                                  data: img)]
        }
    }

    var isCookie: Bool {
        false
    }

    var basicAuth: [String: String]? {
        nil
    }
}
