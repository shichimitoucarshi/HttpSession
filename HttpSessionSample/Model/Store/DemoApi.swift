//
//  DemoApi.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/09/28.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import HttpSession

enum DemoApi {
    case zen
    case post(param: Tapul)
    case download
    case upload
}

extension DemoApi: ApiProtocol {
    var isNeedDefaultHeader: Bool {
        return true
    }

    var domain: String {
        switch self {
        case .zen, .post, .upload:
            return "https://sevens-api.herokuapp.com"
        case .download:
            return "https://shichimitoucarashi.com"
        }
    }

    var endPoint: String {
        switch self {
        case .zen:
            return "getApi.json"
        case .post:
            return "postApi.json"
        case .download:
            return "apple-movie.mp4"
        case .upload:
            return "imageUp.json"
        }
    }

    var method: Http.Method {
        switch self {
        case .zen:
            return .get
        case .post, .upload:
            return .post
        case .download:
            return .get
        }
    }

    var header: [String: String]? {
        return nil
    }

    var params: [String: String]? {
        switch self {
        case .zen:
            return nil
        case let .post(val):
            return [val.value.0: val.value.1]
        case .upload:
            return nil
        case .download:
            return nil
        }
    }

    var multipart: [Multipartible]? {
        switch self {
        case .upload:
            let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
            let img: Data
            do {
                img = try Data(contentsOf: URL(fileURLWithPath: image!))
            } catch {
                img = Data()
            }

            return [Multipartible(key: "img",
                                  fileName: "Hello.txt",
                                  mineType: "text/plain",
                                  data: img)]
        case .zen, .post, .download:
            return nil
        }
    }

    var isCookie: Bool {
        return false
    }

    var basicAuth: [String: String]? {
        return nil
    }
}
