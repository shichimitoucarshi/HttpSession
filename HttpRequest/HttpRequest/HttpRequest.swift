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
    case post = "POST"
    case get  = "GET"
    case Put = "PUT"
    case Delete = "DELETE"
}


class HttpRequest : NSObject, URLSessionDataDelegate {
    
    /*
     * member's value
     *
     */
    var responseData: Data = Data()
    var response: HTTPURLResponse!
    var dataTask: URLSessionDataTask!
    var url: String!
    var request: Request?
    
    var isCookie: Bool = false
    
    init(url: String, method: HTTPMethod, cookie: Bool = false){
        self.isCookie = cookie
        self.request = Request(url: url, method: method,cookie:cookie)
    }
    /*
     * Callback function
     * success Handler
     *
     */
    public typealias completionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
    var successHandler: completionHandler?
    
    public func getHttp (completion: @escaping(Data?, HTTPURLResponse?,Error?) -> Void) {
        
        self.sendRequest(req: (self.request?.urlReq)!) { (data, responce, error) in
            completion(data,responce,error)
        }
    }
    
    public func postHttp(param: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        self.sendRequest(request: (self.request?.postHttp(param: param))!)
    }
    
    public func signIn(param: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        self.isCookie = true
        self.sendRequest(request: (self.request?.postHttp(param: param))!)
    }
    
    public func upload(param: Dictionary<String, MultipartDto>,
                       completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        self.sendRequest(request: (self.request?.multipartReq(param: param))!)
    }
    
    /*
     * Follower List
     * HttpMethod: GET
     * Authenticate: Beare
     * 
     */
    public func twitFollowerList(url: String, beare: String, userId: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        
        self.successHandler = completionHandler
        
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
        
        self.successHandler = completionHandler
        
        let request: URLRequest = Request(url: url, method: .post).twitBeareRequest(param: param)
        self.sendRequest(request: request)
    }
    
    /*
     * Twitter Request Token
     * HttpMethod: POST
     * Authenticate: OAuth
     *
     */
    public func twitOAuthenticate(url: String,  param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.successHandler = completionHandler
        self.sendRequest(request: (self.request?.twitterOAuth(param: param))!)
    }
    
    /*
     * HttpMethod: POST
     * Twitter Access Token
     * Authenticate OAuth
     *
     */
    public func twitOAuth(param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.successHandler = completionHandler
        self.sendRequest(request: (self.request?.twitterOAuth(param: param))!)
    }
    
    public func twitCDN(url: String, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        
        let request: URLRequest = URLRequest(url: URL(string: url)!)
        
        self.sendRequest(request: request)
    }
    
    func showUser(parame: [String:String], success: @escaping (Data?,HTTPURLResponse?, Error?) -> Void) {
        self.successHandler = success
        let u = "https://api.twitter.com/1.1/users/show.json"
        let request: URLRequest = Request(url: u, method: .get).twitterUser(param: parame)
        self.sendRequest(request: request)
    }
    
    func postTweet (tweet: String, img: UIImage, success: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        self.successHandler = success
        let u: String = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        
        let request: URLRequest = Request(url: u, method: .post).postTweet(tweet: tweet, imgae: img)
        self.sendRequest(request: request)
        
    }
    
    /*
     * send Request
     */
    func sendRequest(request: URLRequest){
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.dataTask = session.dataTask(with: request)
        self.dataTask.resume()
    }
    
    func sendRequest(req: URLRequest, completion: @escaping(Data?,HTTPURLResponse?, Error?) -> Void) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        self.dataTask = session.dataTask(with: req, completionHandler: {
            (data, resp, err) in
            completion(data,resp as? HTTPURLResponse,err)
        })
        self.dataTask.resume()
    }
    
    // Delegate method
    
    /*
     * Get Responce and Result
     *
     *
     */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        #if os(iOS)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        #endif
        
        if error != nil {
            return
        }
        print (self.response)
        
        if self.isCookie == true{
            self.isCookie = false
            Cookie.shared.set(responce: response)
        }
        /*
         * status code
         */
        self.successHandler!(self.responseData,self.response,error)
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
        self.responseData.count = 0
        completionHandler(.allow)

    }
}
