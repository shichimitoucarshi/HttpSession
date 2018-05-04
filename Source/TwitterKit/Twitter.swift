//
//  Twitter.swift
//  HttpSessionSample
//
//  Created by Shichimitoucarashi on 2018/04/28.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import Foundation
import UIKit

open class Twitter:Http {
    
    
    public static func oAuth (urlType: String, success: @escaping () -> Void, failuer: @escaping(Error?,HTTPURLResponse?)->Void ) {
        
        Twitter().twitOAuth(urlType: urlType, completion: { (data, response, error) in
            let responseData = String(data:data!, encoding:String.Encoding.utf8)
            var attributes = responseData?.queryStringParameters
            
            if let attrbute = attributes?["oauth_token"] {
                let url: String = "https://api.twitter.com/oauth/authorize?oauth_token=" + attrbute
                let queryURL = URL(string: url)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(queryURL, options: [:])
                } else {
                    UIApplication.shared.openURL(queryURL)
                }
                success()
            }else{
                failuer(error,response)
            }
        })
    }
    
    public static func access(token: String, success: @escaping (TwiterUser)-> Void, failuer: @escaping (HTTPURLResponse?,Error?)->Void){
        Twitter().accessToken(token: token, success: { (twitter) in
            success(twitter)
        }, failuer: { (error,responce)  in
            failuer(responce,error)
        })
    }
    
    public static func beare(success: @escaping ()-> Void, failuer: @escaping(HTTPURLResponse?, Error?) -> Void ) {
        Twitter().bearerToken(completion: { (data, responce, error) in
            if (responce?.statusCode)! < 300 {
                TwitterKey.shared.setBeareToken(data: data!)
                success()
            }else{
                failuer(responce,error)
            }
        })
    }
    
    public static func tweet (tweet: String, img: UIImage, success: @escaping(Data?)-> Void, failuer: @escaping(HTTPURLResponse?, Error?) -> Void) {
        Twitter().tweet(tweet: tweet, img: img, success: { (data, responce, error) in
            if (responce?.statusCode)! < 300 {
                success(data)
            }else{
                failuer(responce,error)
            }
        })
    }
    
    public static func users(success:@escaping(Data?)->Void, failuer:@escaping(HTTPURLResponse?,Error?)->Void){
        Twitter().users(userId: TwitAccount.shared.twitter.userId, success: { (data, responce, error) in
            if (responce?.statusCode)! < 300 {
                success(data)
            }else{
                failuer(responce, error)
            }
        })
    }
    
    public static func follwers (success: @escaping(Data?)-> Void, failuer: @escaping(HTTPURLResponse?,Error?)->Void){
        Twitter().follower(userId: TwitAccount.shared.twitter.userId, completion: { (data, responce, error) in
            if (responce?.statusCode)! < 300 {
                success(data)
            }else{
                failuer(responce,error)
            }
        })
    }
    
     /*
     * Twitter OAuth
     *
     */
    public func twitOAuth(urlType: String, completion: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        let url = "https://api.twitter.com/oauth/request_token"
        let httpSession = Http(url: url, method: .post)
        httpSession.request?.headers(header: self.authorize(url: url, param: ["oauth_callback" : urlType]))
        httpSession.session { (data, responce, error) in
            completion(data, responce,error)
        }
    }
    
    /*
     * Twitter Request Token
     * HttpMethod: POST
     * Authenticate: OAuth
     *
     */
    public func accessToken(token: String,
                       success: @escaping(TwiterUser) -> Void, failuer: @escaping(Error?,HTTPURLResponse?)->Void) {
        
        let url = "https://api.twitter.com/oauth/access_token"
        let param = token.queryStringParameters

        Http(url: url, method: .post)
            .session(param: self.authorize(url: url, param: param)) { (data, responce, error) in
            /*
             * set authenticate user's info
             *
             */
            if (responce?.statusCode)! < 300 {
                TwitAccount.shared.setTwiAccount(data: data!)
                success(TwitAccount.shared.twitter)
            }else{
                failuer(error, responce)
            }
        }
    }
    
    /*
     * Follower List
     * HttpMethod: GET
     * Authenticate: Beare
     *
     */
    public func follower(userId: String, completion: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        
        self.completion = completion
        let url = "https://api.twitter.com/1.1/followers/list.json"
        let user: String = URI().twitterEncode(param: ["user_id":userId])
        let followers: String = url + "?" + user
        let request: URLRequest = Request(url: followers, method: .get)
            .twitFollowersRequest(beare: TwitterKey.shared.beareToken!)
        self.sendRequest(request: request)
    }
    
    /*
     * Twitter Beare Token Request
     * HttpMethod: POST
     * Authenticate: BeareToken
     *
     */
    public func bearerToken(completion: @escaping(Data?,HTTPURLResponse?,Error?) -> Void) {
        let url:String = "https://api.twitter.com/oauth2/token"
        self.completion = completion
        
        let request: URLRequest = Request(url: url, method: .post).twitBeareRequest(param:["grant_type" : "client_credentials"])
        self.sendRequest(request: request)
    }
    
    func users(userId: String, success: @escaping (Data?,HTTPURLResponse?, Error?) -> Void) {
        self.completion = success
        let u = "https://api.twitter.com/1.1/users/show.json"
        let request: URLRequest = Request(url: u, method: .get).twitterUser(param: ["user_id":userId])
        self.sendRequest(request: request)
    }
    
    public func tweet (tweet: String, img: UIImage, success: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        self.completion = success
        let u: String = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        self.sendRequest(request: (Request(url:u, method: .post).postTweet(tweet: tweet, imgae: img)))
    }
    
    private func authorize(url: String, param: [String: String], upload: Bool = false) -> [String: String] {
        let signature: String = OAuthKit().authorizationHeader(for: URL(string: url)!,
                                                               method: .post,
                                                               parameters: param,
                                                               isMediaUpload: false)
        return ["Authorization": signature]
    }
}
