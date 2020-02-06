//
//  LoginController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/06.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        
        return label
    }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView()
        
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ic_mail_outline_white_2x")
        imageView.alpha = 0.87
        view.addSubview(imageView)
        imageView.centerY(inView: view)
        imageView.anchor(left : view.leftAnchor,paddingLeft: 8, width:24,height: 24)
        
        view.addSubview(emailTextField)
        emailTextField.centerY(inView: view)
        emailTextField.anchor(left : imageView.rightAnchor, bottom:  view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8 , paddingBottom: 8)
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor,bottom: view.bottomAnchor, right: view.rightAnchor,paddingLeft: 8,height: 0.75)
        
        return view
    }()
    
    private let emailTextField : UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        return tf
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        
        setupUI()
        
    }
    
    //MARK: Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(InView: view)
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingBottom: 0, paddingRight: 0,height: 50)
    }

}

