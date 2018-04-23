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
    
    init() {
        
    }
    
    func oAuth () {
        HttpRequest().twitOAuthenticate(url: "https://api.twitter.com/oauth/request_token",
                                        param: ["oauth_callback" : "brewtter://success"],
                                        completionHandler: { (data, response, error) in
                                            
                                            let responseData = String(data:data!, encoding:String.Encoding.utf8)
                                            
                                            var attributes = responseData?.queryStringParameters
                                            
                                            let url: String = "https://api.twitter.com/oauth/authorize?oauth_token=" + (attributes?["oauth_token"])!
                                            
                                            let queryURL = URL(string: url)!
                                            
                                            UIApplication.shared.openURL(queryURL)
        })
    }
    
}
