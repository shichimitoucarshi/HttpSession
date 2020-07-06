//
//  Auth.swift
//  HttpSession
//
//  Created by Shichimitoucarashi on 2020/02/29.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import Foundation

open class Auth {
    public static let user: String = "user"
    public static let password: String = "password"

    public static func basic (user: String, password: String) -> String {
        let basic = "\(user):\(password)".data(using: .utf8)
        let basicAuth = "Basic \(String(describing: basic?.base64EncodedString(options: [])))"
        return basicAuth
    }
}
