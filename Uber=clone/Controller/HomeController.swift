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

private let reuserIdentifier = "LocationCell"

class HomeController : UIViewController {
    
    private let mapview = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    private let tableView = UITableView()
    private final let locationInputViewHeight : CGFloat = 200
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.isHidden = true
        // check Login
        checkUserIsLogin()
        enableLocationaService()
        fetchUserData()
        

      
        
        
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
    
    func fetchUserData() {
        Service.shared.fetchCurrentUserData { (user) in
            self.locationInputView.titleLabel.text = user.fullname
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            // aync
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("can't Sign Out")
        }
    }
    
    //MARK: Helpers
    
    
    func configureUI() {
        configureMapView()
        
        // add activationView
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(InView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.delegate = self
        // hidedn
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            // present
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
        
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

extension HomeController {
    
    func enableLocationaService() {
       
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted , .denied:
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("Always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
   
}

//MARK: Activation VIew Delegate

extension HomeController : LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
 
}

//MARK: InputVIew Delegate

extension HomeController : LocationInputViewDelegate {
    
    func handleBackBUttonTapped() {
        locationInputView.removeFromSuperview()
        
        UIView.animate(withDuration: 1) {
            // dismiss tableView
            self.tableView.frame.origin.y = self.view.frame.height
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureLocationInputView() {
           
           // inputVIew
           view.addSubview(locationInputView)
           locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, height: locationInputViewHeight)
           locationInputView.alpha = 0
           locationInputView.delegate = self
           
           UIView.animate(withDuration: 0.5, animations: {
               self.locationInputView.alpha = 1
           }) { (_) in
            
            UIView.animate(withDuration: 0.5) {
                
                // 始点
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
           }
           
       }
    
    
}

//MARK: tableView delegate

extension HomeController : UITableViewDelegate, UITableViewDataSource {
    
    // set tableview
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuserIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: height)
        
        
        view.addSubview(tableView)
        
        
    }
    
    // delegate Method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return section == 0 ? 2 : 5
        
        if section == 0 {
            return 2
        }
        
        return 5
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! LocationCell
        
        return cell
    }
    
    // Gray Title
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // blank not nil
        return "   "
    }
    
   
    
    
    
    
}

