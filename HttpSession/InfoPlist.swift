//
//  InfoPlist.swift
//  HttpSession
//
//  Created by keisuke yamagishi on 2023/11/07.
//

import Foundation

public var Version: String? {
    Bundle
        .main
        .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
}
