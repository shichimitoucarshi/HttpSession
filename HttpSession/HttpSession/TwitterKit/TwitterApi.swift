//
//  Tweet.swift
//  HttpSessionSample
//
//  Created by Shichimitoucarashi on 2018/04/25.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import Foundation
import UIKit

class TwitterApi: HttpSession {
    
    override init(){
        super.init()
    }
    
    override init(url: String, method: HTTPMethod, cookie: Bool = false) {
        super.init(url: url, method: method)
    }
    
    public static func oAuth (urlType: String) {
        
        TwitterApi(url: "https://api.twitter.com/oauth/request_token", method: .post)
            .twitterOAuth(param: ["oauth_callback" : urlType],
                          completionHandler: { (data, response, error) in
                            let responseData = String(data:data!, encoding:String.Encoding.utf8)
                            var attributes = responseData?.queryStringParameters
                            let url: String = "https://api.twitter.com/oauth/authorize?oauth_token=" + (attributes?["oauth_token"])!
                            let queryURL = URL(string: url)!
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(queryURL, options: [:])
                            } else {
                                UIApplication.shared.openURL(queryURL)
                            }
            })
    }
    
    public static func requestToken(token: String, completion :@escaping(Twiter) -> Void){
        let splitParam = token.queryStringParameters
        /*
         * Twitter OAuth Request Token
         * URL: https://api.twitter.com/oauth/access_token
         *
         */
        TwitterApi(url: "https://api.twitter.com/oauth/access_token",method: .post)
            .requestToken(param: splitParam,
                          completionHandler: { (data, response, error) in
                            
                            let accesToken:[String:String] = (String(data: data!, encoding: .utf8)?.queryStringParameters)!
                            print (accesToken)
                            /*
                             * set authenticate user's info
                             *
                             */
                            TwitAccount.shared.setTwiAccount(data: data!)
                            
                            completion(TwitAccount.shared.twitter)
            })
    }
    
    func tweet (tweet: String, img: UIImage, success: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        self.successHandler = success
        let u: String = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        self.sendRequest(request: (Request(url:u, method: .post).postTweet(tweet: tweet, imgae: img)))
    }
    
    func users(parame: [String:String], success: @escaping (Data?,HTTPURLResponse?, Error?) -> Void) {
        self.successHandler = success
        let u = "https://api.twitter.com/1.1/users/show.json"
        let request: URLRequest = Request(url: u, method: .get).twitterUser(param: parame)
        self.sendRequest(request: request)
    }
    
    /*
     * Twitter Beare Token Request
     * HttpMethod: POST
     * Authenticate: BeareToken
     *
     */
    public func bearerToken(url: String, param: Dictionary<String, String>, completionHandler: @escaping(Data?,HTTPURLResponse?,Error?) -> Void) {
        
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
    public func twitterOAuth(param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.successHandler = completionHandler
        
        self.sendRequest(request: (self.request!.twitterOAuth(param: param)))
    }
    
    /*
     * HttpMethod: POST
     * Twitter Access Token
     * Authenticate OAuth
     *
     */
    public func requestToken(param: Dictionary<String, String>, completionHandler: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        
        self.successHandler = completionHandler
        self.sendRequest(request: (self.request?.twitterOAuth(param: param))!)
    }
}
