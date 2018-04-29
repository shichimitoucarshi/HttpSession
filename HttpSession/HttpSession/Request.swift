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
    
    /*
     * Initializer
     * parame: URLRequest
     *
     */
    public init (url: String, method: HTTPMethod, cookie: Bool = false){
        self.url = URL(string: url)!
        self.urlReq = URLRequest(url: self.url)
        self.urlReq.httpMethod = method.rawValue
        self.urlReq.allHTTPHeaderFields = Request.appInfo
        if cookie == true {
            self.urlReq.httpShouldHandleCookies = false
            self.urlReq.allHTTPHeaderFields = Cookie.shared.get(url: url)
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
            return "HttpSession"
        }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLang,
            "User-Agent": userAgent
        ]
    }()
    
    public func headers(header: [String:String]) {
        
        _ = header.map { (arg) -> [String: String] in
            self.urlReq.setValue(arg.value, forHTTPHeaderField: arg.key)
            return [arg.key:arg.value]
        }
    }
    
    public func post(param: Dictionary<String, String>) -> URLRequest{
        
        let value: String = URI().encode(param: param)
        let pData: Data = value.data(using: .utf8)! as Data
        
        let header: [String:String] = ["Content-Type": "application/x-www-form-urlencoded",
                                       "Accept": "application/x-www-form-urlencoded",
                                       "Content-Length": pData.count.description]
        
        self.headers(header: header)
        
        self.urlReq.httpBody = pData as Data
        
        return self.urlReq
    }
    
    public func multipart(param: Dictionary<String, MultipartDto>) -> URLRequest{
        
        let multipart: Multipart = Multipart()
        let data:Data = multipart.multiparts(params: param)
        
        let header = ["Content-Type": "multipart/form-data; boundary=\(multipart.bundary)",
            "Content-Length":"\(data.count)"]
        
        self.headers(header: header)
        self.urlReq.httpBody = data
        return self.urlReq
    }
    
    public func twitterUser(param: [String: String]) -> URLRequest {
        let signature: String = OAuthKit().authorizationHeader(for: self.url!,method: .get ,parameters: param, isMediaUpload: false)
        self.urlReq.setValue(signature, forHTTPHeaderField: "Authorization")
        let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(4))!
        self.urlReq.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
        let query = param.urlEncodedQueryString(using: .utf8)
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
    public func twitBeareRequest(param: Dictionary<String, String>) -> URLRequest{
        let credential = URI().base64EncodedCredentials()
        self.urlReq.setValue("Basic " + credential, forHTTPHeaderField: "Authorization")
        self.urlReq.setValue("application/x-www-form-urlencoded; charset=utf8", forHTTPHeaderField: "Content-Type")
        let value: String = URI().twitterEncode(param: param)
        let par: NSData = value.data(using: String.Encoding.utf8)! as NSData
        self.urlReq.httpBody = par as Data
        return self.urlReq
    }
    
    public func postTweet(tweet: String, imgae: UIImage) -> URLRequest {
        
        let boundary = "--" + UUID().uuidString
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        self.urlReq!.setValue(contentType, forHTTPHeaderField:"Content-Type")
        
        var body: Data = Data()
        
        var parameters = Dictionary<String, Any>()
        parameters["status"] = tweet
        
        let signature: String = OAuthKit().authorizationHeader(for: self.url!,method: .post ,parameters:parameters, isMediaUpload: true)
        
        self.urlReq.setValue(signature, forHTTPHeaderField: "Authorization")
        
        let multipartData = Multipart.mulipartContent(with: boundary, data: UIImagePNGRepresentation(imgae)!, fileName: "media.jpg", parameterName: "media[]", mimeType: "application/octet-stream")
        body.append(multipartData)
        
        for (key, value): (String, Any) in parameters {
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)".data(using: .utf8)!)
        }
        
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        self.urlReq!.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        self.urlReq!.httpBody = body
        
        return self.urlReq
    }
    
    /*
     * Authenticate: Bearer
     * Header: Authorization Bearer
     * Twitter Followe list
     *
     */
    public func twitFollowersRequest(beare: String) -> URLRequest{
        self.urlReq.setValue("Bearer " + beare, forHTTPHeaderField: "Authorization")
        return self.urlReq
    }
}
