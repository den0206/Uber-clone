//
//  LocationInputActivationView.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

protocol LocationInputActivationViewDelegate : class {
    func presentLocationInputView()
}

class LocationInputActivationView : UIView {
    
    weak var delegate : LocationInputActivationViewDelegate?
    
    private let indicatorVIew : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLabel : UILabel = {
        let label = UILabel()
        label.text = "Where To?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        // shadow
        addShadow()
        
        addSubview(indicatorVIew)
        indicatorVIew.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorVIew.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorVIew.rightAnchor, paddingLeft: 20)
        
        // Gesture Recognaizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowLocationInputView))
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Handlers
    
    @objc func handleShowLocationInputView() {
        delegate?.presentLocationInputView()
    }
}
