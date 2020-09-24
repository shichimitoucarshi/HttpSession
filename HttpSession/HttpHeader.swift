//
//  HttpHeader.swift
//  HttpSession
//
//  Created by Shichimitoucarashi on 2020/07/06.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import Foundation

public class HttpHeader {
    public static let appInfo: [String: String] = {
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

                    let osName: String = {
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

                    return "\(osName)/\(version)"
                }()
                return "\(executable)/\(appVersion) (\(bundle)) kCFBundleVersionKey/\(appBuild) \(version)"
            }
            return "HttpSession: \(VERSION)"
        }()

        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLang,
            "User-Agent": userAgent,
        ]
    }()

    static func postHeader(_ contentLength: String) -> [String: String] {
        return ["Content-Type": "application/x-www-form-urlencoded",
                "Accept": "application/x-www-form-urlencoded",
                "Content-Length": contentLength]
    }

    static func multipart(_ bundary: String) -> [String: String] {
        return ["Content-Type": "multipart/form-data; boundary=\(bundary)"]
    }

    static func basicAuthenticate(auth: [String: String]) -> [String: String] {
        return ["Authorization": Auth.basic(user: auth[Auth.user] ?? "",
                                            password: auth[Auth.password] ?? "")]
    }
}

extension URLRequest {
    public mutating func headers(header: [String: String]) {
        for (key, value) in header {
            setValue(value, forHTTPHeaderField: key)
        }
    }
}
