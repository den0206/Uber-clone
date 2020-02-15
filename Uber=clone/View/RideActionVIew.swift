//
//  RideActionVIew.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/11.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import MapKit


protocol RideActionViewDelegate : class{
    
    func uploadTrip(_ view : RideActionView)
    func cancelTrip()
    func pickUpPassanger()
}

enum RidectionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassanger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction : CustomStringConvertible{
    case requestRide
    case cancel
    case getDirection
    case pickUp
    case dropOff
    
    var description : String {
        
        switch  self {
        case .requestRide:
            return "Confirm Uber"
        case .cancel :
            return "Cancel"
        case .getDirection :
           return  "get Direction"
        case .pickUp :
            return "Pick Up"
        case .dropOff :
            return "Drop Off"
        }
    }
    
    init() {
        self = .requestRide
    }
}
class RideActionView: UIView {
    
    var destination : MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addresslabel.text = destination?.address
        }
    }
    
    
    var buttonAction = ButtonAction()
    
    weak var delegate : RideActionViewDelegate?
    var user : FUser?
    
    var config = RidectionViewConfiguration() {
        didSet {
            configureUI(withconfig: config)
        }
    }
    
    //MARK: Propertyt
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Text"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let addresslabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Address"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var  infoView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
//        let label = UILabel ()
//        label.font = UIFont.systemFont(ofSize: 30)
//        label.textColor = .white
//        label.text = "X"
//
        view.addSubview(infoViewLabel)
        infoViewLabel.centerY(inView: view)
        infoViewLabel.centerX(InView: view)
        return view
        
    }()
    
    private let infoViewLabel :UILabel = {
        
        let label = UILabel ()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        return label
        
    }()
    
    let uberInfoLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "UBER X"
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Confirm UberX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
   
    //MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addresslabel])
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(InView: self)
        stack.anchor(top : topAnchor,paddingTop:  13)
        
        addSubview(infoView)
        infoView.centerX(InView: self)
        infoView.anchor(top : stack.bottomAnchor, paddingTop: 16 )
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(uberInfoLabel)
        uberInfoLabel.centerX(InView: self)
        uberInfoLabel.anchor(top : infoView.bottomAnchor, paddingTop: 8)
        
        //MARK: Separator Line
        
        let separotorView = UIView()
        separotorView.backgroundColor = .lightGray
        addSubview(separotorView)
        separotorView.anchor(top: uberInfoLabel.bottomAnchor,  left: leftAnchor, right: rightAnchor, paddingTop: 4,height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor( left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,  paddingLeft: 12, paddingBottom: 12, paddingRight: 12,height: 50)
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Selectors
    
    @objc func actionButtonPressed() {
        switch buttonAction  {
        
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirection:
            print("Get Direction")
        case .pickUp:
            delegate?.pickUpPassanger()
        case .dropOff:
            print("Drop OFf")
        }
    }
    
    //MARK: Helper
    
    private func configureUI(withconfig config : RidectionViewConfiguration) {
        switch config {
        
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripAccepted:
            guard let user = user else {return}
            
            if user.accountType == .passanger {
                titleLabel.text = "Route To Passanger"
                buttonAction = .getDirection
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                titleLabel.text = "Driver To Route"
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            
        case .driverArrived :
            guard let user = user else {return}
            if user.accountType == .driver {
                titleLabel.text = "Driver Arrived"
                addresslabel.text = "Please meet"
                
            }
            
        case .pickupPassanger:
            
            titleLabel.text = "Arrivaed At @assnger"
            buttonAction = .pickUp
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            
            guard let user = user else {return}
            
            if user.accountType == .driver {
                actionButton.setTitle("Progress", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirection
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "route to Description"
        case .endTrip:
            guard let user = user else {return}
            
            if user.accountType == .driver {
                actionButton.setTitle("End Of TRIP", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
        
        }
    }
}
