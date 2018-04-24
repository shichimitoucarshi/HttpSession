//
//  TwitterAuth.swift
//  Breris
//
//  Created by Shichimitoucarashi on 2018/01/03.
//  Copyright © 2018年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

open class TwitterAuth {
    
    public static func twitterOAuth (urlType: String) {
        HttpSession(url: "https://api.twitter.com/oauth/request_token", method: .post)
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
        HttpSession(url: "https://api.twitter.com/oauth/access_token",method: .post)
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
    
}
