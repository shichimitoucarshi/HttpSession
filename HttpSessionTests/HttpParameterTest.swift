//
//  HttpParameterTest.swift
//  HttpSessionTests
//
//  Created by keisuke yamagishi on 2021/03/11.
//

@testable import HttpSession
import XCTest

class HttpParameterTest: XCTestCase {
    let params = ["Test": "Value",
                  "Test1": "Value2"]

    func testParameterNotDefaultHeader() {
        let http = Http.request(url: TestUrl,
                                method: .post,
                                isNeedDefaultHeader: false,
                                params: params)
        let testValue = URI.encode(params)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == HttpHeader.postHeader((testValue?.count.description)!))
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == testValue)
    }

    func testParameterAddDefaultHeader() {
        let http = Http.request(url: TestUrl,
                                method: .post,
                                isNeedDefaultHeader: true,
                                params: params)
        let testValue = URI.encode(params)
        var testHeaderValue = HttpHeader.appInfo

        for (key, value) in HttpHeader.postHeader((testValue?.count.description)!) {
            testHeaderValue[key] = value
        }

        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == testHeaderValue)
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == testValue)
    }

    func testParameterIsEmpty() {
        let http = Http.request(url: TestUrl,
                                method: .post,
                                isNeedDefaultHeader: false,
                                params: [:])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == nil)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == [:])
    }

    func testParameterIsNil() {
        let http = Http.request(url: TestUrl,
                                method: .post,
                                isNeedDefaultHeader: false,
                                params: nil)
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == nil)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == [:])
    }

    func testParameterIsNilGetMethod() {
        let http = Http.request(url: TestUrl,
                                method: .get,
                                isNeedDefaultHeader: false,
                                params: params)
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields != nil)
    }

    func testParameterIsNilHeadMethod() {
        let http = Http.request(url: TestUrl,
                                method: .head,
                                isNeedDefaultHeader: false,
                                params: params)
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields != nil)
    }

    func testParameterIsNilDeleteMethod() {
        let http = Http.request(url: TestUrl,
                                method: .delete,
                                isNeedDefaultHeader: false,
                                params: params)
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields != nil)
    }

    func testParameterIsNotNilPutMethod() {
        let http = Http.request(url: TestUrl,
                                method: .put,
                                isNeedDefaultHeader: false,
                                params: params)
        let testValue = URI.encode(params)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == HttpHeader.postHeader((testValue?.count.description)!))
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == testValue)
    }

    func testParameterIsNotNilConnectMethod() {
        let http = Http.request(url: TestUrl,
                                method: .connect,
                                isNeedDefaultHeader: false,
                                params: params)
        let testValue = URI.encode(params)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == HttpHeader.postHeader((testValue?.count.description)!))
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == testValue)
    }

    func testParameterIsNotNilOptionsMethod() {
        let http = Http.request(url: TestUrl,
                                method: .options,
                                isNeedDefaultHeader: false,
                                params: params)
        let testValue = URI.encode(params)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == HttpHeader.postHeader((testValue?.count.description)!))
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == testValue)
    }

    func testParameterIsNotNilOptionMethod() {
        let http = Http.request(url: TestUrl,
                                method: .trace,
                                isNeedDefaultHeader: false,
                                params: params)
        let testValue = URI.encode(params)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == HttpHeader.postHeader((testValue?.count.description)!))
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == testValue)
    }
}
