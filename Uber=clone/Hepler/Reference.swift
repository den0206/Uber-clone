//
//  Reference.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum References : String {
    case User
    case Driver_Location
    case Trip
}

func firebaseReferences(_ references : References) -> CollectionReference {
    return Firestore.firestore().collection(references.rawValue)
}
