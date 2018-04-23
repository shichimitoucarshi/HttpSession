//
//  BeareToken.swift
//  twit
//
//  Created by shichimi on 2017/03/20.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

class BeareToken{
    
    static let shared: BeareToken = BeareToken()
    
    var beareToken: String!
    
    private init(){
        self.beareToken = ""
    }
    
    public func setBeareToken(data: Data){
        let beare = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
        self.beareToken = beare?["access_token"]
    }
}
