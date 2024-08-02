//
//  HttpURLTest.swift
//  HttpSessionTests
//
//  Created by keisuke yamagishi on 2021/03/13.
//

@testable import HttpSession
import XCTest

class HttpURLTest: XCTestCase {
    func testURLVaridationSuccessTest() {
        do {
            _ = try "https://shichimitoucarashi.herokuapp.com/".toUrl()
        } catch {
            print("Excetion: \(error)")
            XCTFail()
        }
    }

    func testURLVaridationFailuerTest() {
        do {
            _ = try "".toUrl()
            XCTFail()
        } catch {
            print("Excetion: \(error)")
        }
    }
}
