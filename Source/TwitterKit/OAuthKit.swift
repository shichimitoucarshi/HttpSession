//
//  OAuthKit.swift
//  twit
//
//  Created by shichimi on 2017/03/19.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

open class OAuthKit{
    
    public var consumerSecret: String!
    public var tokenSecret: String!
    
    /*
     * initialize function
     * initialize menbers value
     * comsumerSecret: String
     * tokenSecret: String
     */
    public init(){
        self.consumerSecret = ""
        self.tokenSecret = ""
    }
    
    /*
     * initialize function
     * initialize members value
     * set comsumerSecret value
     * set tokenSecret value
     */
    public init(comsumersecret: String, tokenSecret: String) {
        self.consumerSecret = comsumersecret
        self.tokenSecret = tokenSecret
    }
    
    public struct OAuth{
        static let version = "1.0"
        static let signatureMethod = "HMAC-SHA1"
    }
    
    /*
     * create headers
     *
     *
     */
    public func authorizationHeader(for url: URL,method: HTTPMethod, parameters: Dictionary<String, Any>, isMediaUpload: Bool) -> String {
        var authorization = Dictionary<String, Any>()
        authorization["oauth_version"] = OAuth.version
        authorization["oauth_signature_method"] =  OAuth.signatureMethod
        authorization["oauth_consumer_key"] = TwitterApi.comsumerKey
        authorization["oauth_timestamp"] = String(Int(Date().timeIntervalSince1970))
        authorization["oauth_nonce"] = UUID().uuidString
        
        authorization["oauth_token"] ??= TwitAccount.shared.twitter.oAuth.token //RMTwitterManager().selectToken().first?.oAuthToken
        
        for (key, value) in parameters where key.hasPrefix("oauth_") {
            authorization.updateValue(value, forKey: key)
        }
        
        let combinedParameters = authorization +| parameters
        
        let final = isMediaUpload ? authorization : combinedParameters
        
        authorization["oauth_signature"] = self.oauthSignature(for: url,method: method, parameters: final)
        
        let authorizationParameterComponents = authorization.urlEncodedQueryString(using: .utf8).components(separatedBy: "&").sorted()
        
        var headerComponents = [String]()
        for component in authorizationParameterComponents {
            let subcomponent = component.components(separatedBy: "=")
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        return "OAuth " + headerComponents.joined(separator: ", ")
    }
    
    /*
     * OAuth signature
     * create signature value
     *
     */
    public func oauthSignature(for url: URL, method: HTTPMethod, parameters: Dictionary<String, Any>) -> String {
        let tokenSecret = TwitAccount.shared.twitter.oAuth.secret //RMTwitterManager().selectToken().first?.oAuthSecret ?? ""
        let encodedConsumerSecret = TwitterApi.comsumerSecret.UrlEncode()
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        let parameterComponents = parameters.urlEncodedQueryString(using: .utf8).components(separatedBy: "&").sorted()
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.UrlEncode()
        let encodedURL = url.absoluteString.UrlEncode()
        let signatureBaseString = "\(method.rawValue)&\(encodedURL)&\(encodedParameterString)"
        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }
}
