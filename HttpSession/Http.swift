//
//  HttpRequest.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/11.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

let VERSION = "1.8.0"
public protocol HttpApi: AnyObject {
    associatedtype ApiType: ApiProtocol

    func send(api: ApiType, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func download(api: ApiType,
                  data: Data?,
                  progress: @escaping (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void,
                  download: @escaping (_ path: URL?) -> Void,
                  completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func upload(api: ApiType,
                progress: ((_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void)?,
                completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func cancel(byResumeData: @escaping (Data?) -> Void)

    func cancelTask()
}

public class ApiProvider<Type: ApiProtocol>: HttpApi {
    public typealias ApiType = Type

    public init() {}

    public func send(api: Type,
                     completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).session(completion: completion)
    }

    public func upload(api: Type,
                       progress: ((_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void)? = nil,
                       completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).upload(progress: progress, completion: completion)
    }

    public func download(api: Type,
                         data: Data? = nil,
                         progress: @escaping (Int64, Int64, Int64) -> Void,
                         download: @escaping (URL?) -> Void,
                         completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).download(resumeData: data,
                                        progress: progress,
                                        download: download,
                                        completionHandler: completionHandler)
    }

    public func cancel(byResumeData: @escaping (Data?) -> Void) {
        Http.shared.cancel { data in
            byResumeData(data)
        }
    }

    public func cancelTask() {
        Http.shared.cancel()
    }
}

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

    let sessionManager: URLSessionManager

    public static let shared = Http()

    init() {
        sessionManager = URLSessionManager()
    }

    private func request(url: String,
                         method: Method = .get,
                         isNeedDefaultHeader: Bool = true,
                         header: [String: String]? = nil,
                         params: [String: String]? = nil,
                         multipart: [Multipartible]? = nil,
                         cookie: Bool = false,
                         basic: [String: String]? = nil) -> Http
    {
        sessionManager.request(url: url,
                               method: method,
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
                              isNeedDefaultHeader: Bool = true,
                              header: [String: String]? = nil,
                              params: [String: String]? = nil,
                              multipart: [Multipartible]? = nil,
                              cookie: Bool = false,
                              basic: [String: String]? = nil) -> Http
    {
        return Http.shared.request(url: url,
                                   method: method,
                                   isNeedDefaultHeader: isNeedDefaultHeader,
                                   header: header,
                                   params: params,
                                   multipart: multipart,
                                   cookie: cookie,
                                   basic: basic)
    }

    public class func request(api: ApiProtocol) -> Http {
        let url = api.domain + "/" + api.endPoint
        return Http.shared.request(url: url,
                                   method: api.method,
                                   isNeedDefaultHeader: api.isNeedDefaultHeader,
                                   header: api.header,
                                   params: api.params,
                                   multipart: api.multipart,
                                   cookie: api.isCookie,
                                   basic: api.basicAuth)
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
