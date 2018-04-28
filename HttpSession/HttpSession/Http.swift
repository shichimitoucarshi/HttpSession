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
        self.sendRequest(request: (self.request?.postHttp(param: param))!)
    }
    
    public func upload(param: Dictionary<String, MultipartDto>,
                       completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completionHandler
        self.sendRequest(request: (self.request?.multipartReq(param: param))!)
    }
    
    /*
     * Follower List
     * HttpMethod: GET
     * Authenticate: Beare
     * 
     */
    public func twitFollowerList(url: String, beare: String, userId: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        
        self.completion = completionHandler
        
        let user: String = URLEncode().URLUTF8Encode(param: userId)
        let followers: String = url + "?" + user
        let request: URLRequest = Request(url: followers, method: .get).twitFollowersRequest(beare: beare)
        self.sendRequest(request: request)
    }
    
    /*
     * Twitter Beare Token Request
     * HttpMethod: POST
     * Authenticate: BeareToken
     *
     */
    public func twitBearerToken(url: String, param: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.completion = completionHandler
        
        let request: URLRequest = Request(url: url, method: .post).twitBeareRequest(param: param)
        self.sendRequest(request: request)
    }
    
    /*
     * Twitter Request Token
     * HttpMethod: POST
     * Authenticate: OAuth
     *
     */
    public func twitterOAuth(param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.completion = completionHandler
        self.sendRequest(request: (self.request?.twitterOAuth(param: param))!)
    }
    
    /*
     * HttpMethod: POST
     * Twitter Access Token
     * Authenticate OAuth
     *
     */
    public func requestToken(param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.completion = completionHandler
        self.sendRequest(request: (self.request?.twitterOAuth(param: param))!)
    }
    
    public func twitCDN(url: String, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void){
        self.completion = completionHandler
        
        let request: URLRequest = URLRequest(url: URL(string: url)!)
        
        self.sendRequest(request: request)
    }
    
    func showUser(parame: [String:String], success: @escaping (Data?,HTTPURLResponse?, Error?) -> Void) {
        self.completion = success
        let u = "https://api.twitter.com/1.1/users/show.json"
        let request: URLRequest = Request(url: u, method: .get).twitterUser(param: parame)
        self.sendRequest(request: request)
    }
    
    func postTweet (tweet: String, img: UIImage, success: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        self.completion = success
        let u: String = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        self.sendRequest(request: (Request(url:u, method: .post).postTweet(tweet: tweet, imgae: img)))
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
//        self.responseData.count = 0
        completionHandler(.allow)

    }
}
