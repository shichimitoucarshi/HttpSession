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
     * param url: String
     *       method: Http.Method
     *       headers: [String: String] nullable default parameter -> nil
     *       parameter: [String: String]? nullable default parameter -> nil
     *       cookie: Bool default parameter -> false
     *       basic:
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

    /*
     * private func buildRequest
     * Function to build a URLRequest
     * param  url: String
     *        method: Http.Method
     * Return URLRequest
     * throws Invalid URL
     */
    private func buildRequest(url: String, method: Http.Method) throws -> URLRequest {
        var request = try URLRequest(url: url.toUrl())
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = HttpHeader.appInfo
        return request
    }

    /*
     * private func isParameter
     * parameter is required or not.
     * param method: Http.Method
     * Return Bool
     */
    private func isParamater (method: Http.Method) -> Bool {
        switch method {
        case .get, .delete, .head:
            return false
        default:
            return true
        }
    }

    /*
     * public func post
     * Create a post method URLRequest.
     * param param: [String: String]
     * Retrun Void
     */
    public func post(param: [String: String]) -> Void {

        guard let value: Data = URI.encode(param: param).data(using: .utf8) as Data? else {
            return
        }
        let header: [String: String] = HttpHeader.postHeader(value.count.description)
        self.urlRequest.headers(header: header)
        self.urlRequest.httpBody = value
    }

    /*
     * public func multipart
     * Create a multipart URLRequest.
     * param [String: Multipart.data]
     * Return URLRequest nullable
     */
    public func multipart(param: [String: Multipart.data]) -> URLRequest? {
        guard self.urlRequest != nil else {
            return nil
        }
        let multipart: Multipart = Multipart()
        let data: Data = multipart.multiparts(params: param)
        self.urlRequest.headers(header: HttpHeader.multipart(multipart.bundary))
        self.urlRequest.httpBody = data
        return self.urlRequest
    }
}
