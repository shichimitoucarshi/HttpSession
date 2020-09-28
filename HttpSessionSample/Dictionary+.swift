//
//  Dictionary+.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/09/28.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import Foundation

extension Dictionary {
    var toStr: String {
        var str: String = ""
        for (key, value) in self {
            str += "key: \(key) value: \(value)\n"
        }
        return str
    }
}
