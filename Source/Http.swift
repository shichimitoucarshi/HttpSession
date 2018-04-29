//
//  HttpRequest.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/11.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

/*
 * Http method
 */
public enum HTTPMethod: String{
    case get  = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
}


open class Http : NSObject, URLSessionDataDelegate {
    
    /*
     * member's value
     *
     */
    public var responseData: Data = Data()
    public var response: HTTPURLResponse?
    public var dataTask: URLSessionDataTask!
    public var url: String?
    public var request: Request?
    
    public var isCookie: Bool = false
    
    public override init(){
        super.init()
    }
    
    public init(url: String, method: HTTPMethod, cookie: Bool = false){
        self.isCookie = cookie
        self.request = Request(url: url, method: method,cookie:cookie)
    }
    
    /*
     * Callback function
     * success Handler
     *
     */
    public typealias completionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
    public var completion: completionHandler?
    
    public func session(param: Dictionary<String, String> = [:], completion: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completion
        self.request?.headers(header: param)
        self.sendRequest(request: (self.request?.post(param: param))!)
    }
    
    public func upload(param: Dictionary<String, MultipartDto>,
                       completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completionHandler
        self.sendRequest(request: (self.request?.multipart(param: param))!)
    }
    
    /*
     * send Request
     */
    func sendRequest(request: URLRequest){
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
        self.completion?(self.responseData,self.response,error)
    }
    
    /*
     * get recive function
     *
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.responseData.append(data)
        
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
