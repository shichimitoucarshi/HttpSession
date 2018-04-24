//
//  TwitAccount.swift
//  twit
//
//  Created by shichimi on 2017/03/20.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

struct OAuth {
    var token: String = ""
    var secret: String = ""
}

struct Twiter {
    var oAuth: OAuth = OAuth()
    var screenName = ""
    var userId = ""
}

class TwitAccount {
    
    public static let shared: TwitAccount = TwitAccount()
    
    /*
     * member value
     *
     */
    var twitter: Twiter = Twiter()
    
    /*
     * initialize
     *
     */
    private init(){}
    
    /*
     * set Twitter' user info
     *
     */
    public func setTwiAccount(data: Data){
        let parameter = String(data:data, encoding:String.Encoding.utf8)
        self.setAccount(param: (parameter?.queryStringParameters)!)
    }
    
    private func setAccount(param: Dictionary<String, String>){
        self.twitter.screenName = param["screen_name"]!
        self.twitter.userId = param["user_id"]!
        self.twitter.oAuth.token = param["oauth_token"]!
        self.twitter.oAuth.secret = param["oauth_token_secret"]!
    }
}
