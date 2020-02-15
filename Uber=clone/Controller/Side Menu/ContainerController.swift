//
//  ContainerController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/15.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class ContainerController : UIViewController {
    
    private let homeController = HomeController()
    private let menuController = MenuController()
    private var isExpand = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backGroundColor
        configureHomeController()
        
        configureMenuController()
    }
    
    func configureHomeController() {
        addChild(homeController)
        homeController.didMove(toParent: self)
        homeController.delegate = self
        
        view.addSubview(homeController.view)
        
    }
    
    func configureMenuController() {
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        
    }
    func animatreMenu(shouldExpand : Bool) {
        
        if shouldExpand {
            // show sideMenu Animation
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: nil)
            
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
