//
//  AuthButton.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/07.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class AuthButton: UIButton {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlueTint
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
