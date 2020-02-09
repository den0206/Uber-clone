//
//  Service.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//


import Firebase
import CoreLocation
import Geofirestore

class Service {
    
    static let shared = Service()
   
    
    //MARK: Get current User
    
    func fetchUserData(uid : String, completion : @escaping(FUser) -> Void){
//        guard let currentId = Auth.auth().currentUser?.uid else {return}
        
        firebaseReferences(.User).document(uid).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                guard let dictionary = snapshot.data() as? [String : Any] else {return}
                let userId = snapshot.documentID
                let user = FUser(_uid: userId, dictionary: dictionary)
                completion(user)
                
            }
        }
    }
    
    
    
    func fetchDrivers(location : CLLocation , completion : @escaping(FUser) -> Void) {
        let geoFire = GeoFirestore(collectionRef: firebaseReferences(.Driver_Location))
        
        firebaseReferences(.Driver_Location).getDocuments { (snapshot, error) in
            
            
            guard let snapshot = snapshot else {return}
            geoFire.query(withCenter: location, radius: 1000).observe(.documentEntered) { (uid, location) in
                if let uid = uid, let location = location {
                    self.fetchUserData(uid: uid) { (user) in
                        var driver = user
                        driver.location = location
                        completion(driver)
                    }
                }
            }
        }
    }
}
