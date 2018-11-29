//
//  Request.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/14.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

public struct MultipartDto {
    public var fileName: String!
    public var mimeType: String!
    public var data: Data!
    public init(){
        self.fileName = ""
        self.mimeType = ""
        self.data = Data()
    }
}

open class Request {
    
    var url: URL!
    var urlReq: URLRequest!
    var reqHeaders: [String:String] = [:]
    
    /*
     * Initializer
     * parame: URLRequest
     *
     */
    public init (url: String,
                 method: Http.method,
                 headers: [String:String]? = nil,
                 parameter:[String:String] = [:],
                 cookie: Bool = false,
                 basic: [String:String]? = nil){
        
        self.url = URL(string: url)!
        self.urlReq = URLRequest(url: self.url)
        self.urlReq.httpMethod = method.rawValue
        self.urlReq.allHTTPHeaderFields = Request.appInfo
        
        if let header:[String:String] = headers {
            self.headers(header: header)
        }
        
        if isParamater(method: method) {
            self.post(param: parameter)
        }
        
        if basic != nil{
            self.headers(header: ["Authorization":Auth.basic(user: basic![Auth.user]!,
                                                                         password: basic![Auth.password]!)])
        }
        if cookie == true {
            self.urlReq.httpShouldHandleCookies = false
            self.urlReq.allHTTPHeaderFields = Cookie.shared.get(url: url)
        }
    }
    
    func isParamater (method: Http.method) -> Bool {
        switch method {
        case .get, .delete, .head:
            return false
        default:
            return true
        }
    }
    
    open static let appInfo:[String: String] = {
        
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLang = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                
                let version: String = {
                    let sysVer = ProcessInfo.processInfo.operatingSystemVersion
                    let version = "\(sysVer.majorVersion).\(sysVer.minorVersion).\(sysVer.patchVersion)"
                    
                    let os: String = {
                        #if os(iOS)
                            return "iOS"
                        #elseif os(watchOS)
                            return "watchOS"
                        #elseif os(tvOS)
                            return "tvOS"
                        #elseif os(macOS)
                            return "OS X"
                        #elseif os(Linux)
                            return "Linux"
                        #else
                            return "Unknown"
                        #endif
                    }()
                    
                    return "\(os)/\(version)"
                }()
                return "\(executable)/\(appVersion) (\(bundle)) kCFBundleVersionKey/\(appBuild) \(version)"
            }
            return "HttpSession: \(VERSION)"
        }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLang,
            "User-Agent": userAgent
        ]
    }()
    
    public func headers(header: [String:String]) {
        for (key,value) in header {
            self.urlReq.setValue(value, forHTTPHeaderField:key)
        }
    }
    
    func basicAuthenticate (auth: [String:String]) -> [String:String] {
        return ["Authorization": Auth.basic(user: auth[Auth.user]!,
                                                        password: auth[Auth.password]!)]
    }
    
    public func post(param: [String:String]) {
        
        let value: String = URI.encode(param: param)
        let pData: Data = value.data(using: .utf8)! as Data
        
        let header: [String:String] = ["Content-Type": "application/x-www-form-urlencoded",
                                       "Accept": "application/x-www-form-urlencoded",
                                       "Content-Length": pData.count.description]
        
        self.headers(header: header)
        
        self.urlReq.httpBody = pData as Data
    }
    
    public func multipart(param: Dictionary<String, MultipartDto>) -> URLRequest {
        
        let multipart: Multipart = Multipart()
        let data:Data = multipart.multiparts(params: param)
        
        let header = ["Content-Type": "multipart/form-data; boundary=\(multipart.bundary)"]
        
        self.headers(header: header)
        self.urlReq.httpBody = data
        return self.urlReq
    }
    
    public func twitterUser(param: [String: String]) -> URLRequest {
        
        let header: [String:String] = ["Authorization": self.signature(param: param, isUpload: false),
                                       "Content-Type":"application/x-www-form-urlencoded; charset=utf-8"]
        
        self.headers(header: header)
        
        let query = param.encodedQuery(using: .utf8)
        let str = self.url.absoluteString + (self.url.absoluteString.range(of: "?") != nil ? "&" : "?") + query
        self.urlReq.url = URL(string: str)
        return self.urlReq
    }
    
    /*
     * Authenticate: Beare
     * Header: 
     *        * Authorization Basic
     *        * Content-Type application/x-www-form-urlencoded; charset=utf8
     *
     * Twitter Beare Token
     */
    public func twitBeare(param: Dictionary<String, String>) -> URLRequest{
        
        let credential = URI.credentials
        
        let header: [String: String] = ["Authorization": "Basic " + credential,
                                        "Content-Type":"application/x-www-form-urlencoded; charset=utf8"]
        
        self.headers(header: header)

        let value: String = URI.twitterEncode(param: param)
        let body: Data = value.data(using: String.Encoding.utf8)!
        
        self.urlReq.httpBody = body
        return self.urlReq
    }
    
    func signature(param: [String: String], isUpload: Bool) -> String {
        return OAuthKit.authorizationHeader(for: self.url!,method: Http.method(rawValue: self.urlReq.httpMethod!)! ,param:param, isMediaUpload: isUpload)
    }
    
    public func postTweet(tweet: String, img: UIImage) -> URLRequest {
        
        var parameters:[String:String] = [:]
        parameters["status"] = tweet
        
        let tweetMultipart = Multipart()
        
        let body = tweetMultipart.tweetMultipart(param: parameters ,img: img)
        
        let header:[String:String] = ["Content-Type" :"multipart/form-data; boundary=\(tweetMultipart.bundary)",
                                      "Authorization": self.signature(param: parameters, isUpload: true),
                                      "Content-Length": body.count.description]
        
        self.headers(header: header)
        
        self.urlReq!.httpBody = body
        
        return self.urlReq
    }
    
//    /*
//     * Authenticate: Bearer
//     * Header: Authorization Bearer
//     * Twitter Followe list
//     *
//     */
//    public func twitFollowersRequest(beare: String) -> URLRequest{
//        self.urlReq.setValue("Bearer " + beare, forHTTPHeaderField: "Authorization")
//        return self.urlReq
//    }
}
