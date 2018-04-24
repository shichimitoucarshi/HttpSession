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
//        self.oAuth()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if(url.absoluteString.hasPrefix("brewtter://")){
            
            let splitPrefix: String = url.absoluteString.replacingOccurrences(of: "brewtter://success?", with: "")
            
            let splitParam = splitPrefix.queryStringParameters
            
            /*
             * Twitter OAuth Request Token
             * URL: https://api.twitter.com/oauth/access_token
             *
             */
            HttpRequest(url: "https://api.twitter.com/oauth/access_token",method: .post).twitOAuth(param: splitParam,
                                                  completionHandler: { (data, response, error) in
                                                    
                                                    let accesToken:[String:String] = (String(data: data!, encoding: .utf8)?.queryStringParameters)!
                                                    
                                                    print (accesToken)
                                                    /*
                                                     * set authenticate user's info
                                                     *
                                                     */
                                                    TwitAccount.shared.setTwiAccount(data: data!)
            })
        }
        return true
    }
    
    func oAuth(){
        /*
         * Twitter OAuth
         * Twitter Request token
         * URL: https://api.twitter.com/oauth/request_token
         * can get the OAuth token and let the user authenticate.
         *
         */
        HttpRequest(url: "https://api.twitter.com/oauth/request_token", method: .post).twitOAuthenticate(url: "https://api.twitter.com/oauth/request_token",
                                        param: ["oauth_callback" : "httpRequest://success"],
                                        completionHandler: { (data, response, error) in
                                            
                                            let responseData = String(data:data!, encoding:String.Encoding.utf8)
                                            
                                            var attributes = responseData?.queryStringParameters
                                            
                                            let url: String = "https://api.twitter.com/oauth/authorize?oauth_token=" + (attributes?["oauth_token"])!
                                            
                                            let queryURL = URL(string: url)!
                                            
                                            UIApplication.shared.openURL(queryURL)
        })
    }

}

