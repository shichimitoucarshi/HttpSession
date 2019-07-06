//
//  Extention.swift
//  HttpSession
//
//  Created by Shichimitoucarashi on 12/1/18.
//  Copyright © 2018 keisuke yamagishi. All rights reserved.
//

import UIKit

extension String {
    /*
     * Dictionary Converts a value to a string.
     * key=value&key=value
     * {
     *   key : value,
     *   key : value
     * }
     *
     */
    public var queryStringParameters: [String: String] {

        var parameters: [String: String] = [:]

        let scanner = Scanner(string: self)

        var key: NSString?
        var value: NSString?

        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo("=", into: &key)
            scanner.scanString("=", into: nil)

            value = nil
            scanner.scanUpTo("&", into: &value)
            scanner.scanString("&", into: nil)

            if let key = key as String?, let value = value as String? {
                parameters.updateValue(value, forKey: key)
            }
        }
        return parameters
    }
}

extension URI {

    /*
     * Base64 encode with comsumer key and comsmer secret
     * Twitter Beare token
     */
    public static var credentials: String {
        let encodedKey = TwitterKey.shared.api.key.percentEncode() //comsumerKey.UrlEncode()
        let encodedSecret = TwitterKey.shared.api.secret.percentEncode() //comsumerSecret.UrlEncode()
        let bearerTokenCredentials = "\(encodedKey):\(encodedSecret)"
        guard let data = bearerTokenCredentials.data(using: .utf8) else {
            return ""
        }
        return data.base64EncodedString(options: [])
    }

    public static func twitterEncode (param: [String: String]) -> String {
        return URI().twitterEncode(param: param)
    }

    /*
     * It converts the value of Dictionary type
     * URL encoded into a character string and returns it.
     */
    public func twitterEncode(param: [String: String]) -> String {

        var parameter: String = String()

        var keys: Array = Array(param.keys)

        keys.sort {$0 < $1}

        for index in 0..<keys.count {
            let val: String
            if "oauth_callback" == keys[index]
                || "oauth_signature" == keys[index] {
                val = param[keys[index]]!
            } else {
                val = (param[keys[index]]?.percentEncode())!
            }
            if index == (keys.count - 1) {
                parameter += keys[index] + "=" +  val
            } else {
                parameter += keys[index] + "=" +  val + "&"
            }
        }
        return parameter
    }
}

public extension Request {

    func postTweet(url: String, tweet: String, img: UIImage) -> URLRequest {

        var parameters: [String: String] = [:]
        parameters["status"] = tweet

        let tweetMultipart = Multipart()

        let body = tweetMultipart.tweetMultipart(param: parameters, img: img)

        let header: [String: String] = ["Content-Type": "multipart/form-data; boundary=\(tweetMultipart.bundary)",
            "Authorization": Twitter().signature(url: url, method: .post, param: parameters, isUpload: true),
            "Content-Length": body.count.description]

        self.headers(header: header)

        self.urlReq!.httpBody = body

        return self.urlReq
    }

}

extension Multipart {
    func tweetMultipart (param: [String: String], img: UIImage) -> Data {

        var body: Data = Data()

        let multipartData = Multipart.mulipartContent(with: self.bundary, data: img.pngData()!, fileName: "media.jpg", parameterName: "media[]", mimeType: "application/octet-stream")
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
