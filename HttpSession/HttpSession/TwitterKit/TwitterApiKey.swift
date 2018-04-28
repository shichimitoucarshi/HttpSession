//
//  TwitterApiKey.swift
//  twit
//
//  Created by shichimi on 2017/03/20.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

/*
 * set Twitter Comsumer key and Comsumer secret
 * Brewtter App Token
 * https://apps.twitter.com/app/14638399
 */
public struct TwitterApi {
    public var key: String = ""
    public var secret: String = ""
}

open class TwitterKey {
    
    public static let shared: TwitterKey = TwitterKey()
    public var api: TwitterApi = TwitterApi()
    
    private init(){}
    
}
