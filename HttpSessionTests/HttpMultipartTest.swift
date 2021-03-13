//
//  HttpMultipartTest.swift
//  HttpSessionTests
//
//  Created by keisuke yamagishi on 2021/03/13.
//

@testable import HttpSession
import XCTest

class HttpMultipartTest: XCTestCase {
    var multipartible: Multipartible {
        Multipartible(key: "TEST",
                      fileName: "Test.txt",
                      mineType: "text/plain",
                      data: Data())
    }

    func testMultipartIsNilGetMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .get,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == nil)
    }

    func testMultipartIsNilHeadMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .head,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == nil)
    }

    func testMultipartIsNilDeleteMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .delete,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody == nil)
    }

    func testMultipartIsNilPostMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .post,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
    }

    func testMultipartIsNilPutMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .put,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
    }

    func testMultipartIsNilConnectMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .connect,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
    }

    func testMultipartIsNilTraceMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .trace,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
    }

    func testMultipartIsNilOptionsMethod() {
        let http = Http.request(url: "http://httpsession.com",
                                method: .options,
                                isNeedDefaultHeader: false,
                                multipart: [multipartible])
        XCTAssert(http.sessionManager.request?.urlRequest?.httpBody != nil)
    }
}
