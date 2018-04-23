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
    
    var url: URL!
    var urlReq: URLRequest!
    
    /*
     * Initializer
     * parame: URLRequest
     *         URL
     *
     */
    init (url: String, method: HTTPMethod){
        self.url = URL(string: url)!
        self.urlReq = URLRequest(url: self.url)
        self.urlReq.httpMethod = method.rawValue
        self.urlReq.httpShouldHandleCookies = false
        self.urlReq.timeoutInterval = 60
    }
    
    public func getHttp() -> URLRequest {
        return self.urlReq
    }
    
    public func  postHttp (param: Dictionary<String, String>) -> URLRequest{
        self.urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.urlReq.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.urlReq.setValue("application/json", forHTTPHeaderField: "Accept")
        let value: String = URLEncode().URLUTF8Encode(param: param)
        let pData: Data = value.data(using: .utf8)! as Data
        self.urlReq.setValue(pData.count.description, forHTTPHeaderField: "Content-Length")
        self.urlReq.httpBody = pData as Data
        return self.urlReq
    }
    
//    public func PayAppPost (param: Dictionary<String, String>) -> URLRequest{
//        self.urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        self.urlReq.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        self.urlReq.setValue("application/json", forHTTPHeaderField: "Accept")
//        self.urlReq.allHTTPHeaderFields = Request.getCookie()//header
//        let value: String = URLEncode().URLUTF8Encode(param: param)
//        let pData: Data = value.data(using: .utf8)! as Data
//        self.urlReq.setValue(pData.count.description, forHTTPHeaderField: "Content-Length")
//        self.urlReq.httpBody = pData as Data
//        return self.urlReq
//    }
    
    public func PayAppUpoloadImage(param: Dictionary<String, String>, imageParam: Dictionary<String, String>) -> URLRequest{
        
        let uuid = UUID().uuidString
        
        let multi = Multipart(uuid: uuid)
        
        var data = multi.createMultiPart( mineType: "image/jpeg", ImageParam: imageParam)
        
        data.append( multi.textMultiPart(uuid: uuid, param: param))
        self.urlReq.allHTTPHeaderFields = Request.getCookie()
        self.urlReq.httpBody = data
        self.urlReq.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        self.urlReq.setValue(multi.bundary, forHTTPHeaderField: "Content-Type")
        
        return self.urlReq
        
    }
    
    public func PayAppImage(param: Dictionary<String, String>, imageParam: Dictionary<String, Data>) -> URLRequest{
        
        let uuid = UUID().uuidString

        let multi = Multipart(uuid: uuid)
        
        var data = multi.imgMultiPart( mineType: "image/jpeg", ImageParam: imageParam)
        
        self.urlReq.allHTTPHeaderFields = Request.getCookie()
        self.urlReq.httpBody = data
        self.urlReq.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        self.urlReq.setValue(multi.bundary, forHTTPHeaderField: "Content-Type")
        
        return self.urlReq
    }

    /*
     * Authenticate: OAuth
     * Header: Authorization
     *
     * Twitter Request Token, Access Token
     */
    public func twitOAuthRequest(/*oAuth: OAuthKit,*/ param: Dictionary<String, String>) ->URLRequest{
        let signature: String = OAuthKit().authorizationHeader(for: self.url!, method: .post, parameters: param, isMediaUpload: false)
        self.urlReq.setValue(signature, forHTTPHeaderField: "Authorization")
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
        let credential = URLEncode().base64EncodedCredentials()
        self.urlReq.setValue("Basic " + credential, forHTTPHeaderField: "Authorization")
        self.urlReq.setValue("application/x-www-form-urlencoded; charset=utf8", forHTTPHeaderField: "Content-Type")
        let value: String = URLEncode().URLUTF8Encode(param: param)
        let par: NSData = value.data(using: String.Encoding.utf8)! as NSData
        self.urlReq.httpBody = par as Data
        return self.urlReq
    }
    
    func postTweet(tweet: String, imgae: UIImage) -> URLRequest {
        
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
    
//    static public func getCookie() -> [String : String]{
//        let cookie = HTTPCookieStorage.shared.cookies(for: URL(string: POSTKey.authUrl)!)
//        return HTTPCookie.requestHeaderFields(with: cookie!)
//    }
    
    static public func setCookie(responce: URLResponse){
        
        let res = responce as! HTTPURLResponse
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: res.allHeaderFields as! [String : String], for: res.url!)
        
        for i in 0 ..< cookies.count{
            let cookie = cookies[i]
            HTTPCookieStorage.shared.setCookie(cookie)
            
        }
    }
}
