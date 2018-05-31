//
//  HttpMethod.swift
//  swiftDemo
//
//  Created by shichimi on 2017/03/14.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

func rotateLeft(_ v:UInt16, n:UInt16) -> UInt16 {
    return ((v << n) & 0xFFFF) | (v >> (16 - n))
}

func rotateLeft(_ v:UInt32, n:UInt32) -> UInt32 {
    return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
}

func rotateLeft(_ x:UInt64, n:UInt64) -> UInt64 {
    return (x << n) | (x >> (64 - n))
}

infix operator +|

func +| <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

// If `rhs` is not `nil`, assign it to `lhs`.
infix operator ??= : AssignmentPrecedence // { associativity right precedence 90 assignment } // matches other assignment operators

/// If `rhs` is not `nil`, assign it to `lhs`.
func ??=<T>(lhs: inout T?, rhs: T?) {
    guard let rhs = rhs else { return }
    lhs = rhs
}

class Auth {
    
    static let user: String = "user"
    static let password: String = "password"
    
    init() {}
    
    public static func basicAuthenticate (user: String, password: String) -> String {
        let basic = "\(user):\(password)".data(using: .utf8)
        let basicAuth = "Basic \(String(describing: basic!.base64EncodedString(options: [])))"
        return basicAuth
    }
}
