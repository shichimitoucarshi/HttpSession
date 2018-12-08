//
//  ApiProtocol.swift
//  HttpSession
//
//  Created by Shichimitoucarashi on 12/3/18.
//  Copyright © 2018 keisuke yamagishi. All rights reserved.
//

import Foundation

public protocol ApiProtocol {
    
    var domain:String { get }
    
    var endPoint:String { get }
    
    var method: Http.method { get }
    
    var header:[String:String] { get }
    
    var params:[String:String] { get }
    
    var isCookie:Bool { get }
    
    var basicAuth:Bool { get }
    
}
