//
//  URLEncode.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/17.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

class URLEncode : NSObject {
    
    /*
     * Base64 encode with comsumer key and comsmer secret
     * Twitter Beare token
     */
    public func base64EncodedCredentials() -> String {
        let encodedKey = TwitterApi.comsumerKey.UrlEncode()
        let encodedSecret = TwitterApi.comsumerSecret.UrlEncode()
        let bearerTokenCredentials = "\(encodedKey):\(encodedSecret)"
        guard let data = bearerTokenCredentials.data(using: .utf8) else {
            return ""
        }
        return data.base64EncodedString(options: [])
    }
    
    /*
     * It converts the value of Dictionary type
     * URL encoded into a character string and returns it.
     */
    public func URLUTF8Encode(param: Dictionary<String, String>)->String{
        
        var parameter: String = String()
        
        var keys : Array = Array(param.keys)
        
        keys.sort{$0 < $1}
        
        for i in 0..<keys.count {
            let val: String
            if("oauth_callback" == keys[i]
                || "oauth_signature" == keys[i]){
                val = param[keys[i]]!
            }else{
                val = (param[keys[i]]?.UrlEncode())!
            }
            if(i == keys.count-1){
                parameter = parameter + keys[i] + "=" +  val
            }else{
                parameter = parameter + keys[i] + "=" +  val + "&"
            }
        }
        return parameter
    }
}

extension String{
    
    /*
     * PersentEncode
     */
    public func UrlEncode(_ encodeAll: Bool = false) -> String {
        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        if !encodeAll {
            allowedCharacterSet.insert(charactersIn: "[]")
        }
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
    
    /*
     * Dictionary Converts a value to a string.
     * key=value&key=value
     * {
     *   key : value,
     *   key : value
     * }
     *
     */
    public var queryStringParameters: Dictionary<String, String> {
        
        var parameters = Dictionary<String, String>()
        
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

extension Dictionary {
    
    /*
     * encoded Dictionary's value
     *
     */
    public func urlEncodedQueryString(using encoding: String.Encoding) -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString = "\(key)".UrlEncode()
            let valueString = "\(value)".UrlEncode(keyString == "status")
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        return parts.joined(separator: "&")
    }
}

extension Data {
    
    public var rawBytes: [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
    
    public init(bytes: [UInt8]) {
        self.init(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
    
    public mutating func append(_ bytes: [UInt8]) {
        self.append(UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
}

extension Int {
    
    public func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

public func arrayOfBytes<T>(_ value:T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytesPointer = valuePointer.withMemoryRebound(to: UInt8.self, capacity: 1) { $0 }
    var bytes = [UInt8](repeating: 0, count: totalBytes)
    for j in 0..<min(MemoryLayout<T>.size,totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
    }
    
    valuePointer.deinitialize()
    valuePointer.deallocate(capacity: 1)
    
    return bytes
}

