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
    var urlRequest: URLRequest?

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
                isNeedDefaultHeader: Bool = true,
                headers: [String: String]? = nil,
                parameter: [String: String]? = nil,
                multipart: [Multipartible]? = nil,
                cookie: Bool = false,
                basic: [String: String]? = nil)
    {
        do {
            urlRequest = try buildRequest(url, method, isNeedDefaultHeader)
        } catch {
            debugPrint(error)
            return
        }

        if let header = headers {
            configureHeader(header)
        }

        if let param = parameter,
           !param.isEmpty
        {
            configurePostData(param)
        }

        if let multipartData = multipart {
            configureMultipart(multipartData)
        }

        if let basicAuth = basic {
            configureHeader(HttpHeader.basicAuthenticate(basicAuth))
        }

        if cookie {
            urlRequest?.httpShouldHandleCookies = false
            urlRequest?.allHTTPHeaderFields = Cookie.shared.get(url)
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
    private func buildRequest(_ url: String, _ method: Http.Method, _ isNeedDefaultHeader: Bool) throws -> URLRequest {
        var request = try URLRequest(url: url.toUrl())
        request.httpMethod = method.rawValue
        if isNeedDefaultHeader {
            request.allHTTPHeaderFields = HttpHeader.appInfo
        }
        return request
    }

    private func configureHeader(_ header: [String: String]) {
        header.forEach {
            urlRequest?.setValue($0.value, forHTTPHeaderField: $0.key)
        }
    }

    /*
     * public func post
     * Create a post method URLRequest.
     * param param: [String: String]
     * Retrun Void
     */
    public func configurePostData(_ param: [String: String]) {
        guard let value = URI.encode(param) as Data? else {
            return
        }
        let header: [String: String] = HttpHeader.postHeader(value.count.description)
        configureHeader(header)
        urlRequest?.httpBody = value
    }

    /*
     * public func multipart
     * Create a multipart URLRequest.
     * param [String: Multipart.data]
     * Return URLRequest nullable
     */
    public func configureMultipart(_ multiparts: [Multipartible]) {
        guard urlRequest != nil else {
            return
        }

        let multipart = MultipartCreator.multiparts(multiparts)
        configureHeader(HttpHeader.multipart(multipart.boundary))
        urlRequest?.httpBody = multipart.data
    }
}
