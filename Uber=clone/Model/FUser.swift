//
//  FUser.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import CoreLocation

struct FUser {
    let fullname : String
    let email : String
    let accountType : Int
    var location : CLLocation?
    let uid : String
    
    init(_uid : String , dictionary : [String : Any]) {
        self.uid = _uid
        self.fullname = dictionary[kFULLNAME] as? String ?? ""
        self.email = dictionary[kEMAIL] as? String ?? ""
        
        self.accountType = dictionary[kACCOUNTTYPE] as? Int ?? 0
    }
}
