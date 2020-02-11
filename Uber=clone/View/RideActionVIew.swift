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
}

class RideActionView: UIView {
    
    var destination : MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addresslabel.text = destination?.address
        }
    }
    
    weak var delegate : RideActionViewDelegate?

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
        
        let label = UILabel ()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerY(inView: view)
        label.centerX(InView: view)
        return view
        
    }()
    
    let uberXLabel : UILabel = {
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
        
        addSubview(uberXLabel)
        uberXLabel.centerX(InView: self)
        uberXLabel.anchor(top : infoView.bottomAnchor, paddingTop: 8)
        
        //MARK: Separator Line
        
        let separotorView = UIView()
        separotorView.backgroundColor = .lightGray
        addSubview(separotorView)
        separotorView.anchor(top: uberXLabel.bottomAnchor,  left: leftAnchor, right: rightAnchor, paddingTop: 4,height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor( left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,  paddingLeft: 12, paddingBottom: 12, paddingRight: 12,height: 50)
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Selectors
    
    @objc func actionButtonPressed() {
        delegate?.uploadTrip(self)
    }
}
