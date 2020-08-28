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
    public init(url: String,
                method: Http.Method,
                headers: [String: String]? = nil,
                parameter: [String: String]? = nil,
                multipart: [String: Multipart.data]? = nil,
                cookie: Bool = false,
                basic: [String: String]? = nil)
    {
        do {
            urlRequest = try buildRequest(url: url, method: method)
        } catch {
            debugPrint(error)
            return
        }

        if let header: [String: String] = headers {
            urlRequest.headers(header: header)
        }

        if isParamater(method: method),
            let param = parameter
        {
            post(param: param)
        }

        if let multipartData = multipart {
            self.multipart(param: multipartData)
        }

        if let basicAuth = basic {
            urlRequest.headers(header: HttpHeader.basicAuthenticate(auth: basicAuth))
        }

        if cookie == true {
            urlRequest.httpShouldHandleCookies = false
            urlRequest.allHTTPHeaderFields = Cookie.shared.get(url: url)
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
    private func isParamater(method: Http.Method) -> Bool {
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
    public func post(param: [String: String]) {
        guard let value = URI.encode(param: param) as Data? else {
            return
        }
        let header: [String: String] = HttpHeader.postHeader(value.count.description)
        urlRequest.headers(header: header)
        urlRequest.httpBody = value
    }

    /*
     * public func multipart
     * Create a multipart URLRequest.
     * param [String: Multipart.data]
     * Return URLRequest nullable
     */
    public func multipart(param: [String: Multipart.data]) {
        guard urlRequest != nil else {
            return
        }
        let multipart: Multipart = Multipart()
        let data: Data = multipart.multiparts(params: param)
        urlRequest.headers(header: HttpHeader.multipart(multipart.bundary))
        urlRequest.httpBody = data
    }
}
