//
//  HttpHeaderTest.swift
//  HttpSessionTests
//
//  Created by keisuke yamagishi on 2021/03/11.
//

@testable import HttpSession
import XCTest

class HttpHeaderTest: XCTestCase {
    func testDefaultHeaderAssersionTest() {
        let http = Http.request(url: "http://httpsession.com", method: .get, isNeedDefaultHeader: true)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == HttpHeader.appInfo)
    }

    func testDefaultHeaderNil() {
        let http = Http.request(url: "http://httpsession.com", method: .get, isNeedDefaultHeader: false)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == [:])
    }

    func testDefaultHeaderOnlyOtherValue() {
        let header = ["TEST": "Value"]
        let http = Http.request(url: "http://httpsession.com", method: .get, isNeedDefaultHeader: false, header: header)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == header)
    }

    func testDefaultHeaderAddOtherValue() {
        let testHeader = ["TEST": "Value"]
        var defaultHeader = HttpHeader.appInfo
        defaultHeader[testHeader.keys.first!] = testHeader.values.first!
        let http = Http.request(url: "http://httpsession.com", method: .get, isNeedDefaultHeader: true, header: defaultHeader)
        XCTAssert(http.sessionManager.request?.urlRequest?.allHTTPHeaderFields == defaultHeader)
    }
}
