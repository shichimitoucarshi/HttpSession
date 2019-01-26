//
//  AppDelegate.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        TwitterKey.shared.api.key = "NNKAREvWGCn7Riw02gcOYXSVP"
        TwitterKey.shared.api.secret = "pxA18XddLaEvDgonl0ptMBKt54oFCW4GK8ZyPGvbYTitBvH3kM"

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if(url.absoluteString.hasPrefix("httprequest-nnkarevwgcn7riw02gcoyxsvp://")){
            let splitPrefix: String = url.absoluteString.replacingOccurrences(of: "httprequest-nnkarevwgcn7riw02gcoyxsvp://?", with: "")
            Twitter.access(token: splitPrefix, success: { (twitterUSer) in
                Twitter.beare(success: {
                    print ("SUCCESS")
                }, failuer: { (responce, error) in
                    print("Error: \(error) responce: \(responce)")
                })
            }, failuer: { (responce, error) in
                print ("Error: \(error) responce: \(responce)")
            })
            
        }
        return true
    }
}
