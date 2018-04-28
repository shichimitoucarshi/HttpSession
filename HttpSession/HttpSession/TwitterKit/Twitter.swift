//
//  Twitter.swift
//  HttpSessionSample
//
//  Created by Shichimitoucarashi on 2018/04/28.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import Foundation
import UIKit

class Twitter {
    
    var request: Request!
    
    init() {}
    
     /*
     * Twitter OAuth
     *
     */
    public func oAuth(urlType: String, completion: @escaping (Data?,HTTPURLResponse?,Error?) -> Void) {
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
    public func access(token: String,
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
                if let err = error {
                    failuer(err, responce)
                }
            }
        }
    }
    
    private func authorize(url: String, param: [String: String], upload: Bool = false) -> [String: String] {
        let signature: String = OAuthKit().authorizationHeader(for: URL(string: url)!,
                                                               method: .post,
                                                               parameters: param,
                                                               isMediaUpload: false)
        return ["Authorization": signature]
    }
}
