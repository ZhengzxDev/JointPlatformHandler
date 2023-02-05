//
//  ZxCornerView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/17.
//

import UIKit

class ZxCornerView: UIView {
    
    var corners:UIRectCorner = .allCorners
    
    var cornerRadius:CGFloat = 0
    
    private var maskLayer:CAShapeLayer?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard cornerRadius > 0 else {
            self.layer.mask = nil
            return
        }
        if maskLayer == nil{
            maskLayer = CAShapeLayer()
            maskLayer?.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        }
        self.layer.mask = maskLayer
    }
    

}
