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
        Http(url: url, method: .post,header:self.authorize(url: url, param: token.queryStringParameters))
            .session(completion: { (data, responce, error) in
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
        })
    }
    
    /*
     * Follower List
     * HttpMethod: GET
     * Authenticate: Beare
     *
     */
    public func follower(userId: String, completion: @escaping(Data?,HTTPURLResponse?,Error?) -> Void){
        let url = "https://api.twitter.com/1.1/followers/list.json"
        let user: String = URI().encode(param: ["user_id":userId])//twitterEncode(param: ["user_id":userId])
        let followers: String = url + "?" + user
        Http(url: followers, method: .get, header: self.follwerHeader(beare: TwitterKey.shared.beareToken!)).session(completion: completion)
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
        
        let credential = URI.credentials
        
        let header: [String: String] = ["Authorization": "Basic " + credential,
                                        "Content-Type":"application/x-www-form-urlencoded; charset=utf8"]
        Http(url: url, method: .post, header: header,params:["grant_type" : "client_credentials"]).session(completion: completion)
    }
    
    func users(userId: String, success: @escaping (Data?,HTTPURLResponse?, Error?) -> Void) {
        self.completion = success
        let url = "https://api.twitter.com/1.1/users/show.json"
        let param = ["user_id":userId]
        let query = param.encodedQuery(using: .utf8)
        let uri = url + (url.range(of: "?") != nil ? "&" : "?") + query
        
        let header: [String:String] = ["Authorization": self.signature(url: url,
                                                                       method: .get,
                                                                       param: param,
                                                                       isUpload: false),
                                       "Content-Type":"application/x-www-form-urlencoded; charset=utf-8"]
        Http(url: uri, method: .get, header: header).session(completion: success)
    }
    
    public func tweet (tweet: String, img: UIImage, success: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        self.completion = success
        let url: String = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        self.send(request: Request(url: url, method: .post).postTweet(url: url, tweet: tweet, img: img))
    }
    
    private func authorize(url: String, param: [String: String], upload: Bool = false) -> [String: String] {
        let signature: String = OAuthKit().authorizationHeader(for: URL(string: url)!,
                                                               method: .post,
                                                               parameters: param,
                                                               isMediaUpload: false)
        return ["Authorization": signature]
    }
    
    /*
     * Authenticate: Bearer
     * Header: Authorization Bearer
     * Twitter Followe list
     *
     */
    public func follwerHeader(beare: String) -> [String:String]{
        return ["Authorization":"Bearer " + beare]
    }
    
    func signature(url:String,method:Http.method, param: [String: String], isUpload: Bool = false) -> String {
        return OAuthKit.authorizationHeader(for: URL(string: url)!, method: method, param:param, isMediaUpload: isUpload)
    }
}
