//
//  Service.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//


import Firebase

class Service {
    
    static let shared = Service()
   
    
    //MARK: Get current User
    
    func fetchCurrentUserData(completion : @escaping(FUser) -> Void){
        guard let currentId = Auth.auth().currentUser?.uid else {return}
        
        firebaseReferences(.User).document(currentId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                guard let dictionary = snapshot.data() as? [String : Any] else {return}
                let user = FUser(dictionary: dictionary)
                
                completion(user)
                
            }
        }
    }
}
