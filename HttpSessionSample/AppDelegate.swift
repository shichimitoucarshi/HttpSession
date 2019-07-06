//
//  AppDelegate.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit
import HttpSession

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        TwitterKey.shared.api.key = "NNKAREvWGCn7Riw02gcOYXSVP"
        TwitterKey.shared.api.secret = "pxA18XddLaEvDgonl0ptMBKt54oFCW4GK8ZyPGvbYTitBvH3kM"

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        if url.absoluteString.hasPrefix("httprequest-nnkarevwgcn7riw02gcoyxsvp://") {
            let splitPrefix: String = url.absoluteString.replacingOccurrences(of: "httprequest-nnkarevwgcn7riw02gcoyxsvp://?", with: "")
            Twitter.access(token: splitPrefix, success: { (_) in
                Twitter.beare(success: {
                    print ("SUCCESS")
                }, failuer: { (responce, error) in
                    print("Error: \(String(describing: error)) responce: \(String(describing: responce))")
                })
            }, failuer: { (responce, error) in
                print ("Error: \(String(describing: error)) responce: \(String(describing: responce))")
            })

        }
        return true
    }
}
