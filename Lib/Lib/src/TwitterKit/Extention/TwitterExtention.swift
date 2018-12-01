
//
//  Extention.swift
//  HttpSession
//
//  Created by Shichimitoucarashi on 12/1/18.
//  Copyright © 2018 keisuke yamagishi. All rights reserved.
//

import UIKit

public extension Request {
    
    public func postTweet(url:String, tweet: String, img: UIImage) -> URLRequest {
        
        var parameters:[String:String] = [:]
        parameters["status"] = tweet
        
        let tweetMultipart = Multipart()
        
        let body = tweetMultipart.tweetMultipart(param: parameters ,img: img)
        
        let header:[String:String] = ["Content-Type" :"multipart/form-data; boundary=\(tweetMultipart.bundary)",
            "Authorization": Twitter().signature(url: url, method: .post, param: parameters, isUpload: true),
            "Content-Length": body.count.description]
        
        self.headers(header: header)
        
        self.urlReq!.httpBody = body
        
        return self.urlReq
    }

}

extension Multipart{
    func tweetMultipart (param: [String:String], img: UIImage) -> Data {
        
        var body: Data = Data()
        
        let multipartData = Multipart.mulipartContent(with: self.bundary, data: UIImagePNGRepresentation(img)!, fileName: "media.jpg", parameterName: "media[]", mimeType: "application/octet-stream")
        body.append(multipartData)
        
        for (key, value): (String, String) in param {
            body.append("\r\n--\(self.bundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)".data(using: .utf8)!)
        }
        
        body.append("\r\n--\(self.bundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
