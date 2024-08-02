//
//  HttpSessionTests.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 12/1/18.
//  Copyright © 2018 keisuke yamagishi. All rights reserved.
//

@testable import HttpSession
import XCTest

class HttpSessionTests: XCTestCase {
    func testHttpSession() {
        let exp = expectation(description: #function)
        Http.request(url: "https://sevens-api.herokuapp.com/getApi.json", method: .get)
            .session { data, _, _ in
                XCTAssertNotNil(data)
                exp.fulfill()
            }
        wait(for: [exp], timeout: 60.0)
    }

    func testHttpPost() {
        let exp = expectation(description: #function)
        let param = ["http_post": "Http Request POST 😄"]
        Http.request(url: "https://sevens-api.herokuapp.com/postApi.json",
                     method: .post,
                     params: param).session { data, _, _ in
            XCTAssertNotNil(data)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60.0)
    }

    func testHttpCookieSignIn() {
        let exp = expectation(description: #function)
        let param1 = ["http_sign_in": "Http Request SignIn",
                      "userId": "keisukeYamagishi",
                      "password": "password_jisjdhsnjfbns"]
        let url = "https://sevens-api.herokuapp.com/signIn.json"

        Http.request(url: url,
                     method: .post,
                     params: param1).session { data, _, _ in
            XCTAssertNotNil(data)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60.0)
    }

//    func testHttpCookieSignIned() {
//        let exp = expectation(description: #function)
//        Http.request(url: "https://sevens-api.herokuapp.com/signIned.json",
//                     method: .get,
//                     cookie: true).session { data, _, _ in
//            XCTAssert(!Cookie.shared.get("https://sevens-api.herokuapp.com/signIned.json").isEmpty)
//            XCTAssertNotNil(data)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 60.0)
//    }

//    func testHttpMultipart() {
//        let exp = expectation(description: #function)
//        let image: String? = Bundle.main.path(forResource: "Hello", ofType: "txt")
//        var img = Data()
//        do {
//            img = try Data(contentsOf: URL(fileURLWithPath: image!))
//        } catch {}
//
//        let multipartible = Multipartible(key: "img",
//                                          fileName: "Hello.txt",
//                                          mineType: "text/plain",
//                                          data: img)
//
//        Http.request(url: "https://sevens-api.herokuapp.com/imageUp.json",
//                     method: .post, multipart: [multipartible])
//            .upload(completion: { data, _, _ in
//                XCTAssertNotNil(data)
//                exp.fulfill()
//            })
//        wait(for: [exp], timeout: 60.0)
//    }

    func testHttpBasicAuth() {
        let exp = expectation(description: #function)
        let basicAuth: [String: String] = [Auth.user: "httpSession",
                                           Auth.password: "githubHttpsession"]
        Http.request(url: "https://sevens-api.herokuapp.com/basicauth.json",
                     method: .get,
                     basic: basicAuth).session { data, _, _ in
            XCTAssertNotNil(data)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60.0)
    }

    func testHttpDownload() {
        let exp = expectation(description: #function)
        Http.request(url: "https://shichimitoucarashi.com/apple-movie.mp4", method: .get).download(progress: { _, total, expectedToWrite in
            let progress = Float(total) / Float(expectedToWrite)
            print("progress \(progress)")
        }, download: { url in
            print("URL: \(String(describing: url))")
            XCTAssertNotNil(url)
        }) { _, _, _ in
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

//    func testApiProtoccol_Upload() {
//        let exp = expectation(description: #function)
//        Http.request(url: "https://sevens-api.herokuapp.com/imageUp.json",
//                     method: .post,
//                     multipart: Parameter.Multipart)
//            .session { data, _, _ in
//                XCTAssertNotNil(data)
//                exp.fulfill()
//        }
//        wait(for: [exp], timeout: 100.0)
//    }

    func testJsonHttpSession() {
        let exp = expectation(description: #function)
        Http.request(url: "https://decoy-sevens.herokuapp.com/json.json", method: .post)
            .session { data, _, _ in
                XCTAssertNotNil(data)
                exp.fulfill()
            }
        wait(for: [exp], timeout: 60.0)
    }
}
