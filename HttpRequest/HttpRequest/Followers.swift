//
//  Followers.swift
//  twit
//
//  Created by shichimi on 2017/03/20.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

public struct Twits{
    var screenName: String!
    var userImage: String!
}

class Followers{
    
    var userNames: [Twits]!
    
    init(){
        self.userNames = []
    }
    
    /*
     * emurate screen_name's value
     *
     */
    public func setUsersLists(data: Data){
        
        let json = self.JsonConvert(data: data)
        
        print (json)
        
        for user: Dictionary<String, Any> in json {
            var twit: Twits = Twits(screenName: "",userImage: "")
            for (key, value) in user {
                if(key == "screen_name"){
                    twit.screenName = value as? String
                }else if(key == "profile_image_url"){
                    twit.userImage = value as? String
                }
            }
            self.userNames.append(twit)
        }
    }
    
    /*
     * convert data to Dictionary
     *
     */
    func JsonConvert(data: Data) -> [Dictionary<String, Any>]{
        let userJson = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return userJson?["users"] as! [Dictionary<String, Any>]
    }
}
