//
//  HomeController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class HomeController : UIViewController {
    
    private let mapview = MKMapView()
    private let locationmanager = CLLocationManager()
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // check Login
        checkUserIsLogin()
        enableLocationaService()
      
        
        
    }
    
    //MARK: API
    
    private func checkUserIsLogin() {
        
        if Auth.auth().currentUser?.uid == nil {
            // aync
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureUI()
        } 
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("can't Sign Out")
        }
    }
    
    //MARK: Helpers
    
    
    func configureUI() {
        configureMapView()
    }
    
    func configureMapView() {
        view.addSubview(mapview)
        mapview.frame = view.frame
        
        // User Location
        mapview.showsUserLocation = true
        mapview.userTrackingMode = .follow
    }
    
    
}

//MARK: Location Service

extension HomeController  : CLLocationManagerDelegate{
    
    func enableLocationaService() {
        
        locationmanager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationmanager.requestWhenInUseAuthorization()
        case .restricted , .denied:
            break
        case .authorizedAlways:
            print("Always")
            locationmanager.startUpdatingLocation()
            locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationmanager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationmanager.requestAlwaysAuthorization()
        }
    }
}
