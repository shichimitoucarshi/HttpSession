//
//  ApiProtocol.swift
//  HttpSession
//
//  Created by Shichimitoucarashi on 12/3/18.
//  Copyright © 2018 keisuke yamagishi. All rights reserved.
//

import HttpSession

protocol ApiProtocol {
    var domain: String { get }

    var endPoint: String { get }

    var method: Http.Method { get }

    var encode: Http.Encode { get }

    var header: [String: String]? { get }

    var params: [String: String]? { get }

    var isNeedDefaultHeader: Bool { get }

    var multipart: [Multipartible]? { get }

    var isCookie: Bool { get }

    var basicAuth: [String: String]? { get }
}
