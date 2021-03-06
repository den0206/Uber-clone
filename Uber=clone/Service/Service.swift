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

//MARK: - Driver Service

struct DriverService {
    
    static let shared = DriverService()
    
    func obserebeTrip(completion : @escaping(Trip) -> Void) {
        firebaseReferences(.Trip).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                snapshot.documentChanges.forEach { (diff) in
                    
                    if (diff.type == .added) {
                        guard let dictionary = diff.document.data() as? [String : Any] else {return}
                        let trip = Trip(_passangerUid: diff.document.documentID, dictionary: dictionary)
                        
                        completion(trip)
                    }
                    
                    if (diff.type == .modified) {
                        guard let dictionary = diff.document.data() as? [String : Any] else {return}
                        let trip = Trip(_passangerUid: diff.document.documentID, dictionary: dictionary)
                        
                        completion(trip)
                    }
                    
                    
                }
                
            }
        }
    }
    
    func observeTripCancelled(trip : Trip, completion : @escaping(Bool) -> Void) {
        
        // except When Complete
        
        
        firebaseReferences(.Trip).document(trip.passangerUId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            completion(snapshot.exists)
            
        }
    }
    
    func updateDriverLocation(location : CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let geofire = GeoFirestore(collectionRef: firebaseReferences(.Driver_Location))
        geofire.setLocation(location: location, forDocumentWithID: uid)
    }
    
    
    func updateTripState(trip : Trip, state : TripState, completion : @escaping(Error?) -> Void) {
        
        firebaseReferences(.Trip).document(trip.passangerUId).updateData([kSTATE : state.rawValue]) { (error) in
            
            if error != nil {
                completion(error)
                return
            }
        }
        
        //        if state == .completed {
        //            firebaseReferences(.Trip).document(trip.passangerUId)
        //        }
    }
}

//MARK: - Passanger Service

struct PassangerService {
    static let shared = PassangerService()
    
    func fetchDrivers(location : CLLocation , completion : @escaping(FUser) -> Void) {
        let geoFire = GeoFirestore(collectionRef: firebaseReferences(.Driver_Location))
        
        firebaseReferences(.Driver_Location).getDocuments { (snapshot, error) in
            
            
            //            guard let snapshot = snapshot else {return}
            geoFire.query(withCenter: location, radius: 1000).observe(.documentEntered) { (uid, location) in
                if let uid = uid, let location = location {
                    Service.shared.fetchUserData(uid: uid) { (user) in
                        var driver = user
                        driver.location = location
                        completion(driver)
                    }
                }
            }
            
            geoFire.query(withCenter: location, radius: 1000).observe(.documentMoved) { (uid, location) in
                if let uid = uid, let location = location {
                    Service.shared.fetchUserData(uid: uid) { (user) in
                        var driver = user
                        driver.location = location
                        completion(driver)
                    }
                }
            }
        }
    }
    
    func uploadTrip(_ pickurCoodinates : CLLocationCoordinate2D, desitinationCoodinates : CLLocationCoordinate2D, completion : @escaping(Error?) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let picupArray = [pickurCoodinates.latitude, pickurCoodinates.longitude]
        let destinationArray = [desitinationCoodinates.latitude, desitinationCoodinates.longitude ]
        
        let values = [kPICKUPCOODINATES : picupArray,
                      kDESTINATONCOODINATES : destinationArray,
                      kSTATE : TripState.requested.rawValue
            
            ] as [String : Any]
        
        firebaseReferences(.Trip).document(uid).setData(values) { (error) in
            
            completion(error)
        }
    }
    
    func acceptTrip(trip : Trip) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        let values = [kDRIVAERUID : currentUid,
                      kSTATE : TripState.accepted.rawValue] as [String : Any]
        
        firebaseReferences(.Trip).document(trip.passangerUId).updateData(values)
    }
    
    func observeCurrentTrip(completion : @escaping(Trip) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        firebaseReferences(.Trip).document(currentUid).addSnapshotListener { (snapshot, error) in
            guard let snapshot  = snapshot else {return}
            
            if snapshot.exists {
                guard let dictionary = snapshot.data() as? [String :Any] else {return}
                let uid = snapshot.documentID
                let trip = Trip(_passangerUid: uid, dictionary: dictionary)
                completion(trip)
                
            }
        }
    }
    
    func deleteTrip(completion : @escaping(Error?) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        firebaseReferences(.Trip).document(uid).delete { (error) in
            completion(error)
        }
    }
    
    func saveLocation(locationString : String, type : LocationType, completion : @escaping(Error?) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let key : String = type == .home ? kHOMELOCATION : kWORKLOCATION
        
        
        firebaseReferences(.User).document(uid).updateData([key : locationString]) { (error) in
            if error != nil {
                completion(error)
            }
        }
    }
    
    
}

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
    

}
