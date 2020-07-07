//
//  HttpRequest.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/11.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

let VERSION = "1.4.1"
// swiftlint:disable all
public protocol HttpApi: AnyObject {

    associatedtype ApiType: ApiProtocol

    func send(api: ApiType, completion:@escaping(Data?, HTTPURLResponse?, Error?) -> Void)

    func download(api: ApiType,
                  data: Data?,
                  progress: @escaping (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void,
                  download: @escaping (_ path: URL?) -> Void,
                  completionHandler: @escaping(Data?, HTTPURLResponse?, Error?) -> Void)

    func upload(api: ApiType,
                completion: @escaping(Data?, HTTPURLResponse?, Error?) -> Void)
    
    func cancel (byResumeData: @escaping(Data?) -> Void)

    func cancelTask()
}

public class ApiProvider<Type: ApiProtocol>: HttpApi {

    public typealias ApiType = Type

    public init(){}

    public func send(api: Type,
                        completion: @escaping(Data?, HTTPURLResponse?, Error?) -> Void) {
        Http.request(api: api).session(completion: completion)
    }

    public func upload(api: Type,
                       completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        Http.request(api: api).upload(completionHandler: completion)
    }

    public func download(api: Type,
                         data: Data? = nil,
                         progress: @escaping (Int64, Int64, Int64) -> Void,
                         download: @escaping (URL?) -> Void,
                         completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        Http.request(api: api).download(resumeData: data,
                                        progress: progress,
                                        download: download,
                                        completionHandler: completionHandler)
    }

    public func cancel (byResumeData: @escaping(Data?) -> Void){
        Http.shared.cancel { (data) in
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
        case get  = "GET"
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

    private override init(){
        super.init()
    }

    private func request(url: String,
                         method: Method = .get,
                         header: [String: String]? = nil,
                         params: [String: String]? = nil,
                         multipart: [String: Multipart.data]? = nil,
                         cookie: Bool = false,
                         basic: [String: String]? = nil) -> Http {
        self.data = nil
        self.isCookie = cookie
        self.params = params
        self.request = Request(url: url,
                               method: method,
                               headers: header,
                               parameter: params,
                               multipart: multipart,
                               cookie: cookie,
                               basic: basic)
        return self
    }

    public class func request(url: String,
                        method: Method = .get,
                        header: [String: String]? = nil,
                        params: [String: String]? = nil,
                        multipart: [String: Multipart.data]? = nil,
                        cookie: Bool = false,
                        basic: [String: String]? = nil) -> Http {
        
        return Http.shared.request(url: url,
                                   method: method,
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

    public func session(completion: @escaping(Data?, HTTPURLResponse?, Error?) -> Void) {
        self.completion = completion
        guard let request = self.request?.urlRequest else {
            return
        }
        self.send(request: request)
    }

    public func download (resumeData: Data? = nil,
                          progress: @escaping (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void,
                          download: @escaping (_ path: URL?) -> Void,
                          completionHandler: @escaping(Data?, HTTPURLResponse?, Error?) -> Void) {

        /*
         /_/_/_/_/_/_/_/_/_/_/_/_/_/_/
         
         Resume data handling
         
         /_/_/_/_/_/_/_/_/_/_/_/_/_/_/
         */
        if resumeData == nil {
            self.progress = progress
            self.completion = completionHandler
            self.download = download
            self.sessionConfig = URLSessionConfiguration.background(withIdentifier: "httpSession-background")
            self.session = URLSession(configuration: sessionConfig!, delegate: self, delegateQueue: .main)
            
            guard let urlRequest = self.request?.urlRequest else {
                return
            }
            
            self.downloadTask = self.session?.downloadTask(with: urlRequest)
        } else {
            self.downloadTask = self.session?.downloadTask(withResumeData: resumeData!)
        }
        self.downloadTask?.resume()
    }

    public func cancel (byResumeData: @escaping(Data?) -> Void) {
        downloadTask?.cancel { (data) in
            byResumeData(data)
        }
    }

    public func cancel (){
        self.dataTask?.cancel()
    }

    public func upload(completionHandler: @escaping(Data?, HTTPURLResponse?, Error?) -> Void) {
        self.completion = completionHandler
        guard let urlRequest = self.request?.urlRequest else { return }
        self.send(request: urlRequest)
    }

    /*
     * send Request
     */
    private func send(request: URLRequest) {
        if self.sessionConfig == nil {
            self.sessionConfig = URLSessionConfiguration.default
        }
        let session = URLSession(configuration: self.sessionConfig!, delegate: self, delegateQueue: .main)
        self.dataTask = session.dataTask(with: request)
        self.dataTask?.resume()
    }
}

extension Http: URLSessionDataDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        self.download?(location)
    }

    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        self.progress!(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }

    /*
     * Get Responce and Result
     *
     *
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if self.isCookie == true {
            self.isCookie = false
            Cookie.shared.set(responce: response!)
        }
        self.completion?(self.data, self.response, error)
    }

    /*
     * get recive function
     *
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.recivedData(data: data)
    }

    /*
     * get Http response
     *
     */
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response as? HTTPURLResponse
        completionHandler(.allow)
    }

    func recivedData(data: Data) {
        if self.data == nil {
            self.data = data
        }else{
            self.data?.append(data)
        }
    }
}
// swiftlint:enable all
