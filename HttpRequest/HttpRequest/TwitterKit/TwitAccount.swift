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

class TwitAccount {
    
    public static let shared: TwitAccount = TwitAccount()
    
    /*
     * member value
     *
     */
    var screen_name: String?
    var user_id: String?
    var oAuth: OAuth = OAuth(token: "", secret: "")
    
    /*
     * initialize
     *
     */
    private init(){
        self.screen_name = ""
        self.user_id = ""
    }
    
    /*
     * set Twitter' user info
     *
     */
    public func setTwiAccount(data: Data){
        let parameter = String(data:data, encoding:String.Encoding.utf8)
        self.setAccount(param: (parameter?.queryStringParameters)!)
    }
    
    private func setAccount(param: Dictionary<String, String>){
        self.screen_name = param["screen_name"]
        self.user_id = param["user_id"]
        self.oAuth.token = param["oauth_token"]!
        self.oAuth.secret = param["oauth_token_secret"]!
        
    }
}
