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
    case test3
}

extension TestApi: ApiProtocol {

    var isNeedDefaultHeader: Bool {
        return true
    }

    var domain: String {
        switch self {
        case .test1, .test2, .test3:
            return "https://httpsession.work"
        }
    }

    var endPoint: String {
        switch self {
        case .test1, .test2, .test3:
            return "postApi.json"
        }
    }

    var method: Http.Method {
        switch self {
        case .test1, .test2, .test3:
            return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case .test1, .test2, .test3:
            return nil
        }
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

    var multipart: [String: Multipart.data]? {
        switch self {
        case .test1, .test2:
            return nil
        case .test3:
            var multipartData: Multipart.data = Multipart.data()
            let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
            var img: Data = Data()
            do {
                img = try Data(contentsOf: URL(fileURLWithPath: image!))
            } catch {}
            multipartData.fileName = "Hello.txt"
            multipartData.mimeType = "text/plain"
            multipartData.data = img
            return ["img": multipartData]
        }
    }

    var isCookie: Bool {
        switch self {
        case .test1, .test2, .test3:
            return false
        }
    }

    var basicAuth: [String: String]? {
        switch self {
        case .test1, .test2, .test3:
            return nil
        }
    }
}
