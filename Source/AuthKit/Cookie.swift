//
//  Cookie.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/24.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import Foundation

class Cookie {
    
    static let shared: Cookie = Cookie()
    
    private
    init(){}
    
    public func get(url: String) -> [String : String]{
        let cookie = HTTPCookieStorage.shared.cookies(for: URL(string: url)!)
        return HTTPCookie.requestHeaderFields(with: cookie!)
    }
    
    public func set(responce: URLResponse){
        
        let res = responce as! HTTPURLResponse
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: res.allHeaderFields as! [String : String], for: res.url!)
        
        for i in 0 ..< cookies.count{
            let cookie = cookies[i]
            HTTPCookieStorage.shared.setCookie(cookie)
            
        }
    }
    
}
