//
//  PickupController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/11.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate : class  {
    func didAcceptTrip(_ trip : Trip)
}

class PickupController : UIViewController {
    
    private let mapView = MKMapView()
    weak var delegate : PickupControllerDelegate?
    
    //MARK: Parts
    
    private let cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ic_highlight_off_white").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel : UILabel = {
        let label = UILabel()
        label.text = "pick Up"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTriplButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Accept Trip", for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
    let trip : Trip
    
    init(trip : Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    
    //MARK: Property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        configureUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Selector
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip() {
        // update State
        Service.shared.acceptTrip(trip: trip) { (error) in
            self.delegate?.didAcceptTrip(self.trip)
        }
        dismiss(animated: true, completion: nil)
        
    }
  
    
    //MARK: Helper
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoodinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
//        let placeMark = MKPlacemark(coordinate: trip.pickupCoodinates)
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoodinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
    func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top : view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270 / 2
        mapView.centerX(InView: view)
        mapView.centerY(inView: view, constant: -200)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(InView: view)
        pickupLabel.anchor(top : mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTriplButton)
        acceptTriplButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, height: 50)
  
    }
}
