//
//  ContainerController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/15.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Firebase

class ContainerController : UIViewController {
    
    private let homeController = HomeController()
    private var menuController : MenuController!
    private var isExpand = false
    
    // black view X
    private lazy var xOrigin = self.view.frame.width - 80
    
    // BlackView
    private let blackView = UIView()
    
    private var user : FUser? {
        didSet {
            guard  let user = user else {return}
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserIsLogin()
        
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpand
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func configure() {
        view.backgroundColor = .backGroundColor
        configureHomeController()
        fetchUserData()
        
    }
    
    func configureHomeController() {
        addChild(homeController)
        homeController.didMove(toParent: self)
        homeController.delegate = self
        
        view.addSubview(homeController.view)
        
    }
    
    func configureMenuController(withUser user : FUser) {
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        menuController.delegate = self
        view.insertSubview(menuController.view, at: 0)
        configureBlackView()
    }
    
    func configureBlackView() {
        
        blackView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
        
    }
    func animatreMenu(shouldExpand : Bool, completion : ((Bool) -> Void)? = nil) {
        
        
        if shouldExpand {
            
            // show sideMenu Animation
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                
                // add Black VIew
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            
            // hide black Menu
            self.blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
            
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @objc func dismissMenu() {
        isExpand = false
        animatreMenu(shouldExpand: isExpand)
    }
    
    //MARK: - API
    
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
            configure()
        }
    }
    
    func fetchUserData() {
        guard let currentid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currentid) { (user) in
            self.user = user
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
}

extension ContainerController : HomeControllerDelegate {
    // open side menu
    func handleMenuTpggle() {
        isExpand.toggle()
        
        animatreMenu(shouldExpand: isExpand)
    }
    
    
}

extension ContainerController : SettingsControllerDelegate {
    func updateUser(_ controller: SettingViewController) {
        self.user = controller.user
    }
    
    
}

//MARK: - Menu Controller Delegate

extension ContainerController : MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpand.toggle()
        animatreMenu(shouldExpand: isExpand) { (_) in
            switch option {
            case .yourTrip :
                break
            case.settings :
                
                guard let user = self.user else {return}
                
                let settingVC = SettingViewController(user: user)
                settingVC.delegate = self
                
                let nav = UINavigationController(rootViewController: settingVC)
                
                if #available(iOS 13.0, *) {
                    nav.modalPresentationStyle = .fullScreen
                }
                
                self.present(nav, animated: true, completion: nil)
                
            case.logout :
                let alert = UIAlertController(title: nil, message: "Are you Log out", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
}
