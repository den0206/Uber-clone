//
//  FUser.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation

struct FUser {
    let fullname : String
    let email : String
    let accountType : Int
    
    init(dictionary : [String : Any]) {
        
        self.fullname = dictionary[kFULLNAME] as? String ?? ""
        self.email = dictionary[kEMAIL] as? String ?? ""
        
        self.accountType = dictionary[kACCOUNTTYPE] as? Int ?? 0
    }
}
