//
//  HttpRequest.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/11.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

let VERSION = "1.10.0"

public class Http {
    /*
     * Http method
     */
    public enum Method: String {
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case connect = "CONNECT"
        case options = "OPTIONS"
        case trace = "TRACE"
    }

    public enum Encode {
        case url
        case json
    }

    let sessionManager: URLSessionManager

    public static let shared = Http()

    init() {
        sessionManager = URLSessionManager()
    }

    private func request(url: String,
                         method: Method = .get,
                         encode: Encode = .url,
                         isNeedDefaultHeader: Bool = true,
                         header: [String: String]? = nil,
                         params: [String: String]? = nil,
                         multipart: [Multipartible]? = nil,
                         cookie: Bool = false,
                         basic: [String: String]? = nil) -> Http
    {
        sessionManager.request(url: url,
                               method: method,
                               encode: encode,
                               isNeedDefaultHeader: isNeedDefaultHeader,
                               header: header,
                               params: params,
                               multipart: multipart,
                               cookie: cookie,
                               basic: basic)
        return self
    }

    public class func request(url: String,
                              method: Method = .get,
                              encode: Encode = .url,
                              isNeedDefaultHeader: Bool = true,
                              header: [String: String]? = nil,
                              params: [String: String]? = nil,
                              multipart: [Multipartible]? = nil,
                              cookie: Bool = false,
                              basic: [String: String]? = nil) -> Http
    {
        Http.shared.request(url: url,
                                   method: method,
                                   encode: encode,
                                   isNeedDefaultHeader: isNeedDefaultHeader,
                                   header: header,
                                   params: params,
                                   multipart: multipart,
                                   cookie: cookie,
                                   basic: basic)
    }

    public func session(completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        sessionManager.session(completion: completion)
    }

    public func download(resumeData: Data? = nil,
                         progress: @escaping (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void,
                         download: @escaping (_ path: URL?) -> Void,
                         completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        /*
         /_/_/_/_/_/_/_/_/_/_/_/_/_/_/

         Resume data handling

         /_/_/_/_/_/_/_/_/_/_/_/_/_/_/
         */
        sessionManager.download(resumeData: resumeData,
                                progress: progress,
                                download: download,
                                completion: completionHandler)
    }

    public func cancel(byResumeData: @escaping (Data?) -> Void) {
        sessionManager.cancel(byResumeData: byResumeData)
    }

    public func cancel() {
        sessionManager.cancel()
    }

    public func upload(progress: ((_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void)? = nil,
                       completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        sessionManager.upload(progress: progress, completion: completion)
    }
}
