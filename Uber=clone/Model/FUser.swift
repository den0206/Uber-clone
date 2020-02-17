//
//  FUser.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import CoreLocation

enum AccountType : Int{
    case passanger
    case driver
}

struct FUser {
    let fullname : String
    let email : String
    var accountType : AccountType!
    var location : CLLocation?
    let uid : String
    var homeLocation : String?
    var workLocation :String?
    
    init(_uid : String , dictionary : [String : Any]) {
        self.uid = _uid
        self.fullname = dictionary[kFULLNAME] as? String ?? ""
        self.email = dictionary[kEMAIL] as? String ?? ""
        
        
//        self.accountType = dictionary[kACCOUNTTYPE] as? Int ?? 0
        
        if let home = dictionary[kHOMELOCATION] as? String {
            self.homeLocation = home
        }
        
        if let work = dictionary[kWORKLOCATION] as? String {
            self.workLocation = work
        }
        
        if let index = dictionary[kACCOUNTTYPE] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}


