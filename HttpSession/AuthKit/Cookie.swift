//
//  Cookie.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/24.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import Foundation

open class Cookie {

    public static let shared: Cookie = Cookie()

    private
    init() {}

    public func get(url: String) -> [String: String] {
        let cookie = HTTPCookieStorage.shared.cookies(for: URL(string: url)!)
        return HTTPCookie.requestHeaderFields(with: cookie!)
    }

    public func set(responce: URLResponse) {

        guard let res = responce as? HTTPURLResponse,
            let header = res.allHeaderFields as? [String: String] else { return }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: res.url!)

        for cookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
}
