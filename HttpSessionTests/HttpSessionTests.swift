//
//  HttpSessionTests.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 12/1/18.
//  Copyright © 2018 keisuke yamagishi. All rights reserved.
//

import XCTest
import HttpSession

class HttpSessionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        Http(url: "https://httpsession.work/getApi.json", method: .get)
            .session(completion: { (data, responce, error) in
                
               XCTAssertNil(error)
                
        })
        
        let param = ["http_post":"Http Request POST 😄"]
        
        Http(url: "https://httpsession.work/postApi.json",method: .post,params: param)
            .session(completion: { (data, responce, error) in
                
                
            })
        
        let param1 = ["http_sign_in":"Http Request SignIn",
                     "userId":"keisukeYamagishi",
                     "password": "password_jisjdhsnjfbns"]
        let url = "https://httpsession.work/signIn.json"
        
        Http(url: url, method: .post, params:param)
            .session(completion: { (data, responce, error) in
                XCTAssertNil(error)
            })
        
        Http(url: "https://httpsession.work/signIned.json", method: .get, cookie: true )
            .session(completion: { (data, responce, error) in
                XCTAssertNil(error)
        })
        
        var dto: MultipartDto = MultipartDto()
        let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
        let img: Data = try! Data(contentsOf:  URL(fileURLWithPath:image!))
        
        dto.fileName = "Hello.txt"
        dto.mimeType = "text/plain"
        dto.data = img
        
        Http(url:"https://httpsession.work/imageUp.json",method: .post)
            .upload(param: ["img":dto], completionHandler: { (data, responce, error) in
                
            })
        
        let basicAuth: [String:String] = [Auth.user: "httpSession",
                                          Auth.password: "githubHttpsession"]
        Http(url: "https://httpsession.work/basicauth.json",
             method: .get,
             basic: basicAuth).session(completion: { (data, responce, error) in
                
             })
        
        Twitter.oAuth(urlType: "httpRequest-NNKAREvWGCn7Riw02gcOYXSVP://", success: {
            
            
        }, failuer: { (error, responce) in
            
            print("error: \(String(describing: error)) responce: \(String(describing: responce))")
        })
        
        Twitter.tweet(tweet: "HttpSession https://cocoapods.org/pods/HttpSession", img: UIImage(named: "Re120.jpg")!, success: { (data) in
            
        }, failuer: { (responce, error) in
            print ("responce: \(String(describing: responce)) error: \(String(describing: error))")
        })
        
        Twitter.users(success: { (data) in
        }, failuer: { (responce, error) in
            print ("responce: \(String(describing: responce)) error: \(String(describing: error))")
        })
        
        Twitter.follwers(success: { (data) in
        
        }, failuer: { (responce, error) in
            print ("responce: \(String(describing: responce)) error: \(String(describing: error))")
        })
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
