//
//  CircularProgressView.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/18.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class CircularProgressView :UIView {
    
    var progressLayer : CAShapeLayer!
    var trackLayer : CAShapeLayer!
    var pulsationgLayer : CAShapeLayer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper
    
    private func configureCircleLayers() {
        pulsationgLayer = circleShapeLayer(strokeColor: UIColor.clear, fillColor: .red)
        layer.addSublayer(pulsationgLayer)
        
        trackLayer = circleShapeLayer(strokeColor: .clear, fillColor: .clear)
        layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColor: .systemPink, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
        
    }
    
    private func circleShapeLayer(strokeColor : UIColor, fillColor : UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 32)
        
        let circlarPath = UIBezierPath(arcCenter: center, radius: self.frame.width / 2.5, startAngle: -(.pi / 2), endAngle: 1.5 * .pi, clockwise: true)
        
        layer.path = circlarPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        
        return layer
        
    }
    
    
    
}
