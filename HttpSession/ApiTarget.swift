//
//  ApiTarget.swift
//  HttpSessionSample
//
//  Created by Shichimitoucarashi on 1/1/19.
//  Copyright © 2019 keisuke yamagishi. All rights reserved.
//

import Foundation
import HttpSession

/*
 public protocol ApiProtocol {
 
 var domain:String { get }
 
 var endPoint:String { get }
 
 var method: Http.method { get }
 
 var header:[String:String] { get }
 
 var params:[String:String] { get }
 
 var isCookie:Bool { get }
 
 var basicAuth:Bool { get }
 
 }

 */

enum Cooking {
    case recipes
}

extension Cooking:ApiProtocol {
    
    var basicAuth: [String : String]? {
        return nil
    }
    
    var domain: String{
        return "https://httpsession.work"
    }
    
    var endPoint: String {
        return "getApi.json"
    }
    
    var method: Http.method {
        return .get
    }
    
    var header: [String : String]? {
        return nil
    }
    
    var params: [String : String] {
        return [:]
    }
    
    var isCookie: Bool {
        return false
    }        
}
