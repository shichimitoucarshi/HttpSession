//
//  HttpRequest.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/11.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

let VERSION = "1.7.0"
// swiftlint:disable all
public protocol HttpApi: AnyObject {
    associatedtype ApiType: ApiProtocol

    func send(api: ApiType, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func download(api: ApiType,
                  data: Data?,
                  progress: @escaping (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void,
                  download: @escaping (_ path: URL?) -> Void,
                  completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func upload(api: ApiType,
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
                       completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).upload(completionHandler: completion)
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

open class Http: NSObject {
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

    /*
     * member's value
     *
     */
    public var data: Data?
    public var params: [String: String]?
    public var response: HTTPURLResponse?
    public var dataTask: URLSessionDataTask?
    public var downloadTask: URLSessionDownloadTask?
    public var sessionConfig: URLSessionConfiguration?
    public var session: URLSession?
    public var request: Request?
    public var isCookie: Bool = false
    public static let shared: Http = Http()

    override private init() {
        super.init()
    }

    private func request(url: String,
                         method: Method = .get,
                         isNeedDefaultHeader: Bool = true,
                         header: [String: String]? = nil,
                         params: [String: String]? = nil,
                         multipart: [String: Multipart.data]? = nil,
                         cookie: Bool = false,
                         basic: [String: String]? = nil) -> Http
    {
        data = nil
        isCookie = cookie
        self.params = params
        request = Request(url: url,
                          method: method,
                          isNeedDefaultHeader: isNeedDefaultHeader,
                          headers: header,
                          parameter: params,
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
                              multipart: [String: Multipart.data]? = nil,
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

    /*
     * Callback function
     * success Handler
     *
     */
    public typealias CompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    public typealias ProgressHandler = (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void
    public typealias DownloadHandler = (_ path: URL?) -> Void

    public var progress: ProgressHandler?
    public var completion: CompletionHandler?
    public var download: DownloadHandler?

    public func session(completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.completion = completion
        guard let request = self.request?.urlRequest else {
            return
        }
        send(request: request)
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
        if resumeData == nil {
            self.progress = progress
            completion = completionHandler
            self.download = download
            sessionConfig = URLSessionConfiguration.background(withIdentifier: "httpSession-background")
            session = URLSession(configuration: sessionConfig!, delegate: self, delegateQueue: .main)

            guard let urlRequest = request?.urlRequest else {
                return
            }

            downloadTask = session?.downloadTask(with: urlRequest)
        } else {
            downloadTask = session?.downloadTask(withResumeData: resumeData!)
        }
        downloadTask?.resume()
    }

    public func cancel(byResumeData: @escaping (Data?) -> Void) {
        downloadTask?.cancel { data in
            byResumeData(data)
        }
    }

    public func cancel() {
        dataTask?.cancel()
    }

    public func upload(completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        completion = completionHandler
        guard let urlRequest = request?.urlRequest else { return }
        send(request: urlRequest)
    }

    /*
     * send Request
     */
    private func send(request: URLRequest) {
        if sessionConfig == nil {
            sessionConfig = URLSessionConfiguration.default
        }
        let session = URLSession(configuration: sessionConfig!, delegate: self, delegateQueue: .main)
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }
}

extension Http: URLSessionDataDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    public func urlSession(_: URLSession,
                           downloadTask _: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL)
    {
        download?(location)
    }

    public func urlSession(_: URLSession,
                           downloadTask _: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64)
    {
        progress!(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }

    /*
     * Get Responce and Result
     *
     *
     */
    public func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        if isCookie == true {
            isCookie = false
            Cookie.shared.set(responce: response!)
        }
        completion?(data, response, error)
    }

    /*
     * get recive function
     *
     */
    public func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        recivedData(data: data)
    }

    /*
     * get Http response
     *
     */
    public func urlSession(_: URLSession,
                           dataTask _: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        self.response = response as? HTTPURLResponse
        completionHandler(.allow)
    }

    func recivedData(data: Data) {
        if self.data == nil {
            self.data = data
        } else {
            self.data?.append(data)
        }
    }
}

// swiftlint:enable all
