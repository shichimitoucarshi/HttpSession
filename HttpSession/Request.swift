//
//  Request.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/14.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

open class Request {

    public var urlRequest: URLRequest!

    /*
     * Initializer
     * parame: URLRequest
     *
     */
    public init (url: String,
                 method: Http.Method,
                 headers: [String: String]? = nil,
                 parameter: [String: String] = [:],
                 cookie: Bool = false,
                 basic: [String: String]? = nil) {
        do {
            self.urlRequest = try self.buildRequest(url: url, method: method)
        }catch{
            debugPrint(error)
            return
        }

        if let header: [String: String] = headers {
            self.urlRequest.headers(header: header)
        }

        if isParamater(method: method) {
            self.post(param: parameter)
        }

        if basic != nil {
            self.urlRequest.headers(header: HttpHeader.basicAuthenticate(auth: basic!))
        }
    
        if cookie == true {
            self.urlRequest.httpShouldHandleCookies = false
            self.urlRequest.allHTTPHeaderFields = Cookie.shared.get(url: url)
        }
    }

    private func buildRequest(url: String, method: Http.Method) throws -> URLRequest {
        self.urlRequest = try URLRequest(url: url.toUrl())
        self.urlRequest.httpMethod = method.rawValue
        self.urlRequest.allHTTPHeaderFields = HttpHeader.appInfo
        return self.urlRequest
    }

    func isParamater (method: Http.Method) -> Bool {
        switch method {
        case .get, .delete, .head:
            return false
        default:
            return true
        }
    }

    func post(param: [String: String]) {

        let value: String = URI.encode(param: param)
        let pData: Data = value.data(using: .utf8)! as Data

        let header: [String: String] = HttpHeader.postHeader(pData.count.description)

        self.urlRequest.headers(header: header)

        self.urlRequest.httpBody = pData as Data
    }

    public func multipart(param: [String: Multipart.data]) -> URLRequest? {

        let multipart: Multipart = Multipart()
        let data: Data = multipart.multiparts(params: param)

        let header = HttpHeader.multipart(multipart.bundary)
        guard self.urlRequest != nil else {
            return nil
        }
        self.urlRequest.headers(header: header)
        self.urlRequest.httpBody = data
        return self.urlRequest
    }
}
