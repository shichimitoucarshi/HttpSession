//
//  HttpRequest.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/11.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

let VERSION = "1.3.4"

open class Http:NSObject {
    
    /*
     * Http method
     */
    public enum method: String{
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
    public var data: Data = Data()
    public var params:[String:String]?
    public var response: HTTPURLResponse?
    public var dataTask: URLSessionDataTask!
    public var downloadTask: URLSessionDownloadTask!
    public var url: String?
    public var request: Request?
    
    public var isCookie: Bool = false
    
    public init(url: String,
                method: method = .get,
                header:[String:String]? = nil,
                params:[String:String] = [:],
                cookie: Bool = false,
                basic: [String:String]? = nil){
        
        self.isCookie = cookie
        self.params = params
        self.request = Request(url: url,
                               method: method,
                               headers:header,
                               parameter:params,
                               cookie:cookie,
                               basic: basic)
    }
    
    /*
     * Callback function
     * success Handler
     *
     */
    public typealias completionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    public typealias progressHandler = (_ written: Int64,_ total: Int64,_ expectedToWrite: Int64) -> Void
    public typealias downloadHandler = (_ path: URL?) -> Void
    
    public var progress: progressHandler?
    public var completion: completionHandler?
    public var download: downloadHandler?
    
    public func session(completion: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completion
        self.send(request: (self.request?.urlReq)!)
    }
    
    public func download (progress: @escaping (_ written: Int64,_ total: Int64,_ expectedToWrite: Int64) -> Void,
                          download: @escaping (_ path: URL?) -> Void,
                          completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void) {
        self.progress = progress
        self.completion = completionHandler
        self.download = download
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: "httpSession-background")
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: .main)
        
        self.downloadTask = session.downloadTask(with: (self.request?.urlReq)!)
        self.downloadTask.resume()
    }
    
    public func upload(param: [String: MultipartDto],
                       completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completionHandler
        self.send(request: (self.request?.multipart(param: param))!)
    }
    
    /*
     * send Request
     */
    func send(request: URLRequest){
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.dataTask = session.dataTask(with: request)
        self.dataTask.resume()
    }
}


extension Http:URLSessionDataDelegate,URLSessionDownloadDelegate,URLSessionTaskDelegate {
    
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
        self.progress!(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite)
    }
    
    /*
     * Get Responce and Result
     *
     *
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if self.isCookie == true{
            self.isCookie = false
            Cookie.shared.set(responce: response!)
        }
        self.completion?(self.data,self.response,error)
    }
    
    /*
     * get recive function
     *
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        self.data.append(data)
        
        guard !data.isEmpty else { return }
    }
    
    /*
     * get Http response
     *
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response as? HTTPURLResponse
        completionHandler(.allow)
    }
}
