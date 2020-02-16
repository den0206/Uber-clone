//
//  SidemenuHeader.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/15.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class SideMenuHeader : UIView {
    
    //MARK: - Parts
//    var user : FUser? {
//        didSet {
//
//            self.fullnameLabel.text = user?.fullname
//            self.emailLabel.text = user?.email
//
//        }
//    }
//
    private let user : FUser
    
    private let profileImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    init(user : FUser, frame : CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .backGroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top : topAnchor, left: leftAnchor, paddingTop: 4 , paddingLeft : 12,width: 64,height: 64)
        profileImageView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
        
        
    }
    
    
    
    private lazy var fullnameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textColor = .white
        label.text = user.email
        return label
    }()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
