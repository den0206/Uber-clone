//
//  UserInfoHeader.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/16.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class UserInfoHeader : UIView {
    
    private let user : FUser
    
    //MARK: - Parts
//    private let profileImageView : UIImageView = {
//        let iv = UIImageView()
//        iv.backgroundColor = .lightGray
//        return iv
//    }()
    
    private lazy var profileImageView : UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        
        view.addSubview(initialLabel)
        initialLabel.centerX(InView: view)
        initialLabel.centerY(inView: view)
        
        return view
    }()
    
    private lazy var initialLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42)
        label.textColor = .lightGray
        label.text = user.firstInitial
        return label
    }()
    
    private lazy var fullnameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
       
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    init(user : FUser, frame : CGRect) {
        self.user = user
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        profileImageView.setDimensions(height: 64, width: 64)
        profileImageView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
