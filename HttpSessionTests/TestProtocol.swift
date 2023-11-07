//
//  TestProtocol.swift
//  HttpSessionTests
//
//  Created by Shichimitoucarashi on 2019/12/23.
//  Copyright © 2019 keisuke yamagishi. All rights reserved.
//

import Foundation
import HttpSession
import XCTest

let TestUrl = "https://shichimitoucarashi.herokuapp.com/"

struct Parameter {
    static var Multipart: [Multipartible] {
        guard let image = Bundle.main.path(forResource: "Hello", ofType: "txt") else { return [] }
        var img = Data()
        do {
            img = try Data(contentsOf: URL(fileURLWithPath: image))
        } catch {
            XCTFail()
        }
        return [Multipartible(key: "img",
                              fileName: "Hello.txt",
                              mineType: "text/plain",
                              data: img)]
    }
}
