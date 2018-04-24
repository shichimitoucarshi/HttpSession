//
//  TwitterAuth.swift
//  Breris
//
//  Created by Shichimitoucarashi on 2018/01/03.
//  Copyright © 2018年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

class TwitterAuth {
    
    static func twitterOAuth (urlType: String) {
        HttpRequest(url: "https://api.twitter.com/oauth/request_token", method: .post)
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
    
    static func requestToken(token: String){
        let splitParam = token.queryStringParameters
        /*
         * Twitter OAuth Request Token
         * URL: https://api.twitter.com/oauth/access_token
         *
         */
        HttpRequest(url: "https://api.twitter.com/oauth/access_token",method: .post)
            .twitOAuth(param: splitParam,
                       completionHandler: { (data, response, error) in
                        
                        let accesToken:[String:String] = (String(data: data!, encoding: .utf8)?.queryStringParameters)!
                        print (accesToken)
                        /*
                         * set authenticate user's info
                         *
                         */
                        TwitAccount.shared.setTwiAccount(data: data!)
        })
    }
    
}
