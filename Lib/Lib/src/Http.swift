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

open class Http : NSObject, URLSessionDataDelegate {
    
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
    public var url: String?
    public var request: Request?
    
    public var isCookie: Bool = false
    
    public override init(){
        super.init()
    }
    
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
    
//    public override init(api:ApiProtocol ) {
//        self.init(url: api.domain, method: api., header: <#T##[String : String]?#>, params: <#T##[String : String]#>, cookie: <#T##Bool#>, basic: <#T##[String : String]?#>)
//    }
    
    /*
     * Callback function
     * success Handler
     *
     */
    public typealias completionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
    public var completion: completionHandler?
    
    public func session(completion: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completion
        self.send(request: (self.request?.urlReq)!)
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
