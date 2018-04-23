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
    case Post = "POST"
    case Get  = "GET"
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
    /*
     * Callback function
     * success Handler
     *
     */
    public typealias CompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
    var successHandler: CompletionHandler?
    
    public func getHttp (url: String, completion: @escaping(Data?, HTTPURLResponse?,Error?) -> Void) {
        
        let request: URLRequest = Request(url: url, method: .Get).getHttp()
        self.sendRequest(req: request) { (data, responce, error) in
            completion(data,responce,error)
        }
    }
    
    public func PayAppAuthentication(url: String, param: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        
        self.successHandler = completionHandler
        let request: URLRequest = Request(url: url, method: .Post).PayAppSigin(param: param)
        self.sendRequest(request: request)
    }
    
    public func PayAppPost(url: String, param: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        let request: URLRequest = Request(url: url, method: .Post).PayAppPost(param: param)
        self.sendRequest(request: request)
    }
    
    public func PayAppPostImage(url: String, param: Dictionary<String, String>, imageParam: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        let request: URLRequest = Request(url: url, method: .Post).PayAppUpoloadImage(param: param, imageParam: imageParam)
        self.sendRequest(request: request)
    }
    
    public func PayImage(url: String, param: Dictionary<String, String>, imageParam: Dictionary<String, Data>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        let request: URLRequest = Request(url: url, method: .Post).PayAppImage(param: param, imageParam: imageParam)
        self.sendRequest(request: request)
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
        let request: URLRequest = Request(url: followers, method: .Get).twitFollowersRequest(beare: beare)
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
        
        let request: URLRequest = Request(url: url, method: .Post).twitBeareRequest(param: param)
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
        
        let request: URLRequest = Request(url: url, method: .Post).twitOAuthRequest(/*oAuth: OAuthKit(),*/ param: param)
        self.sendRequest(request: request)
    }
    
    /*
     * HttpMethod: POST
     * Twitter Access Token
     * Authenticate OAuth
     *
     */
    public func twitOAuthenticateSignIn(url: String, /*oAuth: OAuthKit,*/  param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.successHandler = completionHandler
        
        let request: URLRequest = Request(url: url, method: .Post).twitOAuthRequest(/*oAuth: oAuth,*/ param: param)
        self.sendRequest(request: request)
    }
    
    public func twitCDN(url: String, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void){
        self.successHandler = completionHandler
        
        let request: URLRequest = URLRequest(url: URL(string: url)!)
        
        self.sendRequest(request: request)
    }
    
    func showUser(parame: [String:String], success: @escaping (Data?,HTTPURLResponse?, Error?) -> Void) {
        self.successHandler = success
        let u = "https://api.twitter.com/1.1/users/show.json"
        let request: URLRequest = Request(url: u, method: .Get).twitterUser(param: parame)
        self.sendRequest(request: request)
    }
    
    func postTweet (tweet: String, img: UIImage, success: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        self.successHandler = success
        let u: String = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        
        let request: URLRequest = Request(url: u, method: .Post).postTweet(tweet: tweet, imgae: img)
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
        
        /*
         * status code
         */
//        guard self.response.statusCode >= 400 else {
            //let body = String(data: self.responseData, encoding: .utf8)
            //print ("responce: \(body)")
            //print ("get: \(String(describing: String(data:self.responseData, encoding:String.Encoding.utf8)))")
            self.successHandler!(self.responseData,self.response,error)
//            return
//        }
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
