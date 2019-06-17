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

    func testHttpSession() {

        Http(url: "https://httpsession.work/getApi.json", method: .get)
            .session(completion: { (_, _, error) in

                XCTAssertNil(error)

            })
        
    }

    func testHttpPost() {
        let param = ["http_post": "Http Request POST 😄"]
        
        Http(url: "https://httpsession.work/postApi.json", method: .post, params: param)
            .session(completion: { (_, _, _) in
                
            })

    }
    
    func testHttpCookieSignIn() {
        let param1 = ["http_sign_in": "Http Request SignIn",
                      "userId": "keisukeYamagishi",
                      "password": "password_jisjdhsnjfbns"]
        let url = "https://httpsession.work/signIn.json"
        
        Http(url: url, method: .post, params: param)
            .session(completion: { (_, _, error) in
                XCTAssertNil(error)
            })
    }
    
    func testHttpCookieSignIned() {
        Http(url: "https://httpsession.work/signIned.json", method: .get, cookie: true )
            .session(completion: { (_, _, error) in
                XCTAssertNil(error)
            })
    }
    
    func testHttpMultipart() {
        var dto: MultipartDto = MultipartDto()
        let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
        let img: Data = try? Data(contentsOf: URL(fileURLWithPath: image!))
        
        dto.fileName = "Hello.txt"
        dto.mimeType = "text/plain"
        dto.data = img
        
        Http(url: "https://httpsession.work/imageUp.json", method: .post)
            .upload(param: ["img": dto], completionHandler: { (_, _, _) in
                
            })
    }
    
    func testHttpBasicAuth() {
        let basicAuth: [String: String] = [Auth.user: "httpSession",
                                           Auth.password: "githubHttpsession"]
        Http(url: "https://httpsession.work/basicauth.json",
             method: .get,
             basic: basicAuth).session(completion: { (_, _, _) in
                
             })
    }
    
    func testHttpTwitterOAuth() {
        Twitter.oAuth(urlType: "httpRequest-NNKAREvWGCn7Riw02gcOYXSVP://", success: {
            
        }, failuer: { (error, responce) in
            
            print("error: \(String(describing: error)) responce: \(String(describing: responce))")
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
