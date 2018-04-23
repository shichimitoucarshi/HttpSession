//
//  Credential.swift
//  twit
//
//  Created by shichimi on 2017/03/19.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

public class Credential {

    public static var instance: Credential!
    
    var token_key: String?
    var token_secret: String?
    var comsumer_secret: String?
    
    public static func shared () -> Credential {
        if(instance == nil){
            instance = Credential()
        }
        return instance
    }
    
    private init(){
        self.comsumer_secret = ""
    }
}
