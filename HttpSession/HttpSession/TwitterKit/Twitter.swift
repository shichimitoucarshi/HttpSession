//
//  Twitter.swift
//  HttpSessionSample
//
//  Created by Shichimitoucarashi on 2018/04/28.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import Foundation

class Twitter {
    
    var request: Request!
    
    init() {
    }
    
    /*
     * Twitter Request Token
     * HttpMethod: POST
     * Authenticate: OAuth
     *
     */
    /*
     Http(url: "https://api.twitter.com/oauth/request_token", method: .post)
     .twitterOAuth(param: ["oauth_callback" : urlType],
     completionHandler: { (data, response, error) in
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
     }
     completion(data,response,error)
     })
     */
    
    /*
     *
     public static func requestToken(token: String, completion :@escaping(_ twtter: Twiter?, _ data: Data?, _ responce:HTTPURLResponse?, _ error: Error?) -> Void){
     let splitParam = token.queryStringParameters
     /*
     * Twitter OAuth Request Token
     * URL: https://api.twitter.com/oauth/access_token
     *
     */
     Http(url: "https://api.twitter.com/oauth/access_token",method: .post)
     .requestToken(param: splitParam,
     completionHandler: { (data, response, error) in
     
     let accesToken:[String:String] = (String(data: data!, encoding: .utf8)?.queryStringParameters)!
     print (accesToken)
     /*
     * set authenticate user's info
     *
     */
     TwitAccount.shared.setTwiAccount(data: data!)
     
     completion(TwitAccount.shared.twitter,data,response,error)
     })
     }
     
     */
    
    public func oAuth(urlType: String, completion: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
        let url = "https://api.twitter.com/oauth/request_token"
        let signature: String = OAuthKit().authorizationHeader(for: URL(string: url)!,
                                                               method: .post,
                                                               parameters: ["oauth_callback" : urlType],
                                                               isMediaUpload: false)
        
        let httpSession = Http(url: url, method: .post)
        httpSession.request?.urlReq.setValue(signature, forHTTPHeaderField: "Authorization")
        httpSession.session(completion: completion)
    }
    
    public func access(token: String,
                       completion: @escaping(_ data: Data?, _ responce:HTTPURLResponse?, _ error: Error?) -> Void) {
        
        let url = "https://api.twitter.com/oauth/access_token"
        let param = token.queryStringParameters
        let signature: String = OAuthKit().authorizationHeader(for: URL(string: url)!,
                                                               method: .post,
                                                               parameters: param,
                                                               isMediaUpload: false)
        
        let httpSession = Http(url: url, method: .post)
        httpSession.request?.urlReq.setValue(signature, forHTTPHeaderField: "Authorization")
        httpSession.session(completion: completion)
    }
}
