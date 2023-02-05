//
//  JoyStickLayoutContainerView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/23.
//

import UIKit

class JoyStickLayoutContainerView:UIView{
    
    private var tagLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: "#00f1c1")!
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    var component:JoyStickComponent?
    
    private let tagLabelInset:UIEdgeInsets = UIEdgeInsets(top: 4, left: 5, bottom: 4, right: 5)
    
    private let tagLabelTextHeight:CGFloat = 10
    
    private let tagLabelBottomMargin:CGFloat = 4
    
    private let selectColor:UIColor = UIColor(hex: "#00f1c1")!
    
    private let unselectColor:UIColor = UIColor(r: 50, g: 50, b: 50, a: 1)
    
    private let edgeIncrease:CGFloat = 5
    
    private var isSelfEditing:Bool = false
    
    private var componentView:UIView?
    
    convenience init(layoutItem:JoyStickLayoutItem){
        self.init(frame: CGRect.zero)
        self.component = layoutItem.component
        self.frame = CGRect(origin: layoutItem.origin, size: layoutItem.size).insetBy(dx: -edgeIncrease, dy: -edgeIncrease)
        componentView = layoutItem.component.getView()
        self.addSubview(componentView!)
        componentView!.frame = CGRect(origin: CGPoint(x: edgeIncrease, y: edgeIncrease), size: layoutItem.size)
    }
    
    func toggleEditMode(_ value:Bool){
        isSelfEditing = value
        if value{
            self.layer.borderColor = UIColor(hex: "#00f1c1")!.cgColor
            self.layer.borderWidth = 2
            self.layer.cornerRadius = 5
            self.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
            self.tagLabel.text = component?.layoutDescription ?? "未知"
            let textWidth = String.getWidth(self.tagLabel.text!, height: tagLabelTextHeight, font: self.tagLabel.font)
            if tagLabel.superview == nil{
                self.addSubview(tagLabel)
            }
            tagLabel.frame = CGRect(x: 0, y: -(tagLabelBottomMargin+tagLabelTextHeight+tagLabelInset.top+tagLabelInset.bottom), width: textWidth+tagLabelInset.left+tagLabelInset.right, height: tagLabelTextHeight+tagLabelInset.top+tagLabelInset.bottom)
        }
        else{
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0
            self.layer.cornerRadius = 0
            self.backgroundColor = UIColor.clear
            tagLabel.removeFromSuperview()
        }
    }
    
    func setSelected(_ value:Bool){
        guard self.isSelfEditing else { return }
        if value{
            self.layer.borderColor = selectColor.cgColor
            self.tagLabel.backgroundColor = selectColor
        }
        else{
            self.layer.borderColor = unselectColor.cgColor
            self.tagLabel.backgroundColor = unselectColor
        }
    }
    
    func resizeComponentView(_ size:CGSize){
        self.frame = CGRect(origin: CGPoint(x: self.center.x-size.width/2, y: self.center.y-size.height/2), size: size).insetBy(dx: -edgeIncrease, dy: -edgeIncrease)
        componentView?.frame = CGRect(origin: CGPoint(x: edgeIncrease, y: edgeIncrease), size: size)
        componentView?.setNeedsDisplay()
    }
    
    func getComponentViewRect() -> CGRect{
        if componentView != nil{
            let componentViewOrigin = CGPoint(x: self.frame.origin.x+componentView!.frame.origin.x, y: self.frame.origin.y+componentView!.frame.origin.y)
            return CGRect(origin: componentViewOrigin, size: componentView!.frame.size)
        }
        return .zero
    }
}
