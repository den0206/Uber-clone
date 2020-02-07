//
//  SignupController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/07.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class SignupController: UIViewController {
    
   private let titleLabel : UILabel = {
       let label = UILabel()
       label.text = "UBER"
       label.font = UIFont(name: "Avenir-Light", size: 36)
       label.textColor = UIColor(white: 1, alpha: 0.8)
       
       return label
   }()
    
    private lazy var emailContainerVIew : UIView = {
        let view = UIView().inputContainerView(withImage: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private lazy var fullnameContainerView : UIView = {
        let view = UIView().inputContainerView(withImage: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let fullnameTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Fullname", isSecureTextEntry: false)
    }()
    
    private lazy var passwordContainerView : UIView = {
        let view = UIView().inputContainerView(withImage: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private let passwordTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private lazy var accountTypeContainerView : UIView = {
        let view = UIView().inputContainerView(withImage: #imageLiteral(resourceName: "ic_account_box_white_2x"),  segmentControl: accountTypeSegmentControl)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let accountTypeSegmentControl : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver" ])
        sc.backgroundColor = .backGroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    
    private let signUpButton : AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("SignUp", for: .normal)
        return button
    }()
    
    let alredtHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log in", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavifationBar()
        
        configureUI()
    }
    
    private func configureUI() {
        
        view.backgroundColor = UIColor.backGroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(InView: view)
        
        
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerVIew, fullnameContainerView,passwordContainerView, accountTypeContainerView, signUpButton])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
        
        
        view.addSubview(alredtHaveAccountButton)
        alredtHaveAccountButton.centerX(InView: view)
        alredtHaveAccountButton.anchor(bottom : view.safeAreaLayoutGuide.bottomAnchor,height: 12)
        
        
        
    }
    
    private func configureNavifationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Handler
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
}
