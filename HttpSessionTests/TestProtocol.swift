//
//  TestProtocol.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 2019/12/23.
//  Copyright © 2019 keisuke yamagishi. All rights reserved.
//

import Foundation
import HttpSession

enum TestApi {
    case test1
    case test2
}

extension TestApi: ApiProtocol {
    var domain: String {
        switch self {
        case .test1, .test2:
            return "https://httpsession.work"
        }
    }

    var endPoint: String {
        switch self {
        case .test1, .test2:
            return "postApi.json"
        }
    }

    var method: Http.Method {
        switch self {
        case .test1, .test2:
            return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case .test1, .test2:
            return [:]
        }
    }

    var params: [String: String] {
        switch self {
        case .test1:
            return ["http_post":"TEST1"]
        case .test2:
            return ["http_post": "TEST2"]
        }
    }

    var isCookie: Bool {
        switch self {
        case .test1, .test2:
            return false
        }
    }

    var basicAuth: [String: String]? {
        switch self {
        case .test1, .test2:
            return nil
        }
    }
}
