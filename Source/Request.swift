//
//  Request.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/14.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation
import UIKit

class Request {
    
    var Url: URL!
    var request: URLRequest!
    
    /*
     * Initializer
     * parame: URLRequest
     *         URL
     *
     */
    init (url: String, method: HTTPMethod){
        self.Url = URL(string: url)!
        self.request = URLRequest(url: self.Url)
        self.request.httpMethod = method.rawValue
        self.request.httpShouldHandleCookies = false
        self.request.timeoutInterval = 60
    }
    
    public func getHttp() -> URLRequest {
        return self.request
    }
    
    public func  PayAppSigin (param: Dictionary<String, String>) -> URLRequest{
        self.request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        let value: String = URLEncode().URLUTF8Encode(param: param)
        let pData: Data = value.data(using: .utf8)! as Data
        self.request.setValue(pData.count.description, forHTTPHeaderField: "Content-Length")
        self.request.httpBody = pData as Data
        return self.request
    }
    
    public func PayAppPost (param: Dictionary<String, String>) -> URLRequest{
        self.request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.request.allHTTPHeaderFields = Request.getCookie()//header
        let value: String = URLEncode().URLUTF8Encode(param: param)
        let pData: Data = value.data(using: .utf8)! as Data
        self.request.setValue(pData.count.description, forHTTPHeaderField: "Content-Length")
        self.request.httpBody = pData as Data
        return self.request
    }
    
    public func PayAppUpoloadImage(param: Dictionary<String, String>, imageParam: Dictionary<String, String>) -> URLRequest{
        
        let uuid = UUID().uuidString
        
        let multi = Multipart(uuid: uuid)
        
        var data = multi.createMultiPart( mineType: "image/jpeg", ImageParam: imageParam)
        
        data.append( multi.textMultiPart(uuid: uuid, param: param))
        self.request.allHTTPHeaderFields = Request.getCookie()
        self.request.httpBody = data
        self.request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        self.request.setValue(multi.bundary, forHTTPHeaderField: "Content-Type")
        
        return self.request
        
    }
    
    public func PayAppImage(param: Dictionary<String, String>, imageParam: Dictionary<String, Data>) -> URLRequest{
        
        let uuid = UUID().uuidString

        let multi = Multipart(uuid: uuid)
        
        var data = multi.imgMultiPart( mineType: "image/jpeg", ImageParam: imageParam)
        
        self.request.allHTTPHeaderFields = Request.getCookie()
        self.request.httpBody = data
        self.request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        self.request.setValue(multi.bundary, forHTTPHeaderField: "Content-Type")
        
        return self.request
    }

    /*
     * Authenticate: OAuth
     * Header: Authorization
     *
     * Twitter Request Token, Access Token
     */
    public func twitOAuthRequest(/*oAuth: OAuthKit,*/ param: Dictionary<String, String>) ->URLRequest{
        let signature: String = OAuthKit().authorizationHeader(for: self.Url!, method: .Post, parameters: param, isMediaUpload: false)
        self.request.setValue(signature, forHTTPHeaderField: "Authorization")
        return self.request
    }
    
    public func twitterUser(param: [String: String]) -> URLRequest {
        let signature: String = OAuthKit().authorizationHeader(for: self.Url!,method: .Get ,parameters: param, isMediaUpload: false)
        self.request.setValue(signature, forHTTPHeaderField: "Authorization")
        let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(4))!
        self.request.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
        let query = param.urlEncodedQueryString(using: .utf8)
        let str = self.Url.absoluteString + (self.Url.absoluteString.range(of: "?") != nil ? "&" : "?") + query
        self.request.url = URL(string: str)
        return self.request
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
        let credential = URLEncode().base64EncodedCredentials()
        self.request.setValue("Basic " + credential, forHTTPHeaderField: "Authorization")
        self.request.setValue("application/x-www-form-urlencoded; charset=utf8", forHTTPHeaderField: "Content-Type")
        let value: String = URLEncode().URLUTF8Encode(param: param)
        let par: NSData = value.data(using: String.Encoding.utf8)! as NSData
        self.request.httpBody = par as Data
        return self.request
    }
    
    func postTweet(tweet: String, imgae: UIImage) -> URLRequest {
        
        let boundary = "--" + UUID().uuidString
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        self.request!.setValue(contentType, forHTTPHeaderField:"Content-Type")
        
        var body: Data = Data()
        
        var parameters = Dictionary<String, Any>()
        parameters["status"] = tweet
        
        let signature: String = OAuthKit().authorizationHeader(for: self.Url!,method: .Post ,parameters:parameters, isMediaUpload: true)
        
        self.request.setValue(signature, forHTTPHeaderField: "Authorization")
        
        let multipartData = Multipart.mulipartContent(with: boundary, data: UIImagePNGRepresentation(imgae)!, fileName: "media.jpg", parameterName: "media[]", mimeType: "application/octet-stream")
        body.append(multipartData)
        
        for (key, value): (String, Any) in parameters {
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)".data(using: .utf8)!)
        }
        
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        self.request!.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        self.request!.httpBody = body
        
        return self.request
    }
    
    /*
     * Authenticate: Bearer
     * Header: Authorization Bearer
     * Twitter Followe list
     *
     */
    public func twitFollowersRequest(beare: String) -> URLRequest{
        self.request.setValue("Bearer " + beare, forHTTPHeaderField: "Authorization")
        return self.request
    }
    
    static public func getCookie() -> [String : String]{
        let cookie = HTTPCookieStorage.shared.cookies(for: URL(string: POSTKey.authUrl)!)
        return HTTPCookie.requestHeaderFields(with: cookie!)
    }
    
    static public func setCookie(responce: URLResponse){
        
        let res = responce as! HTTPURLResponse
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: res.allHeaderFields as! [String : String], for: res.url!)
        
        for i in 0 ..< cookies.count{
            let cookie = cookies[i]
            HTTPCookieStorage.shared.setCookie(cookie)
            
        }
    }
}
