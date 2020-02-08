//
//  Extensions.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/06.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backGroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
}

extension UIView {
    
    func inputContainerView(withImage : UIImage, textField : UITextField? = nil, segmentControl : UISegmentedControl? = nil) -> UIView{
        
        let view = UIView()
        
        
        let imageView = UIImageView()
        imageView.image = withImage
        imageView.alpha = 0.87
        view.addSubview(imageView)
        
        
        if let textField = textField {
            imageView.centerY(inView: view)
            imageView.anchor(left : view.leftAnchor,paddingLeft: 8, width:24,height: 24)
            
            view.addSubview(textField)
            textField.centerY(inView: view)
            textField.anchor(left : imageView.rightAnchor, bottom:  view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8 , paddingBottom: 8)
            
        }
        
        if let sc = segmentControl {
            imageView.anchor(top : view.topAnchor,  left : view.leftAnchor, paddingTop: -8,  paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(sc)
            sc.anchor(left : view.leftAnchor, right:  view.rightAnchor, paddingLeft:  8, paddingRight: 8)
            sc.centerY(inView: view, constant: 8)
            
        }
        
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor,bottom: view.bottomAnchor, right: view.rightAnchor,paddingLeft: 8,height: 0.75)
        
        return view
        
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight : CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
    }
    
    func centerX(InView view : UIView){
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view : UIView, leftAnchor : NSLayoutXAxisAnchor? = nil, paddingLeft : CGFloat = 0,constant : CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left : left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height : CGFloat, width : CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func addShadow() {
        
        
        // shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.46
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
}

extension UITextField {
    func textField(withPlaceholder : String, isSecureTextEntry : Bool) -> UITextField {
        
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: withPlaceholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        tf.autocapitalizationType = .none
        
        return tf
    }
}
