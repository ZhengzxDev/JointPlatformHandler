//
//  SATabBar.swift
//  schoolAirdrop2.0
//
//  Created by luckyXionzz on 2021/5/2.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

@objc
protocol SATabBarDelegate:CUTabBarDelegate{
    @objc optional func tabBar(tabBar:SATabBar,didPressCenter button:UIButton)
}

class SATabBar:CUTabBar{
    
    
    private var centerButtonWidthRatio:CGFloat = 0.2
    private var centerButtonHeight:CGFloat = 60
    private var centerButtonBackRadius:CGFloat = 30
    private var centerButtonStrokeWidth:CGFloat = 1
    
    private lazy var centerButton:CUButton = {
        let button = CUButton()
        button.setImage(UIImage(named: "tabBar_extra"), for: .normal)
        button.addTarget(self, action: #selector(onPress_center), for: .touchUpInside)
        button.imageSize = CGSize(width: 40, height: 40)
        return button
    }()
    
    
    private var strokeEndColor:UIColor{
        get{
            if #available(iOS 13, *){
                
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark{
                        return UIColor(white: 0.25, alpha: 0)
                    }
                    else{
                        return UIColor(white: 0.85, alpha: 0)
                    }
                }
            }
            else{
                return UIColor(white: 0.85, alpha: 0)
            }
            //return UIColor(white: 0.85, alpha: 1)
        }
    }
    
    private var strokeStartColor:UIColor{
        get{
            if #available(iOS 13, *){
                
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark{
                        return UIColor(white: 0.25, alpha: 1)
                    }
                    else{
                        return UIColor(white: 0.85, alpha: 1)
                    }
                }
            }
            else{
                return UIColor(white: 0.85, alpha: 1)
            }
            //return UIColor(white: 0.85, alpha: 1)
        }
    }
    
    
    private var centerBackView:UIView?
    
    override var delegate: UITabBarDelegate?{
        willSet{
            if let del = newValue as? SATabBarDelegate{
                self.saDelegate = del
            }
        }
    }
    
    private weak var saDelegate:SATabBarDelegate?
    

    
    override func relayout() {
        guard needCustomLayout else { return }
        guard let items = items else { return }
        guard items.count > 0 else { return }
        guard items.count == 4 else { fatalError() }
        
        let buttons = self.subviews.filter{
            return $0.isKind(of: NSClassFromString("UITabBarButton")!)
        }.sorted(by: {
            return $0.frame.origin.x < $1.frame.origin.x
        })
        
        removeAll()
        
        let centerButtonWidth = self.bounds.width * centerButtonWidthRatio
        let otherButtonWidthTotal = self.bounds.width - centerButtonWidth - self.edgeInsets.left - self.edgeInsets.right
        let itemWidth = otherButtonWidthTotal / CGFloat(items.count)
        let itemHeight = self.bounds.height - self.edgeInsets.top - self.edgeInsets.bottom - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        
        let offsetY = self.centerButtonHeight - self.bounds.height + BOTTOM_INSET
        
        let centerButtonFrame = CGRect(x: (self.bounds.width - self.edgeInsets.left - self.edgeInsets.right - centerButtonWidth)/2, y: self.edgeInsets.top - offsetY, width: centerButtonWidth, height: centerButtonHeight)
        
        for (idx,view) in buttons.enumerated(){
            var x:CGFloat = itemWidth * CGFloat(idx) + self.edgeInsets.left
            let y:CGFloat = self.edgeInsets.top
            if idx > 1{
                x += centerButtonWidth
            }
            view.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            guard let cuItem = items[idx] as? CUTabBarItem else { continue }
            
            view.isHidden = true
            
            let container = CUTabBarItemContainer(target: self, tag: idx - 1000)
            container.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            self.containers.append(container)
            self.addSubview(container)
            
            
            //特性设置
            
            
            
            container.addSubview(cuItem.contentView)
            cuItem.contentView.bounds = view.bounds
            cuItem.contentView.frame.origin = CGPoint.zero
            
            //大位置微调
            container.frame.origin.x += cuItem.contentOffset.horizontal
            container.frame.origin.y += cuItem.contentOffset.vertical
            
            //内部控件位置
            
            cuItem.contentView.updateLayout()
            
            if items[idx] != self.selectedItem!{
                cuItem.contentView.onDeselect()
            }
            else{
                cuItem.contentView.onSelect()
            }
            
        }
        centerButton.frame = centerButtonFrame
        
        //中央按钮背景
        if centerBackView == nil{
            centerBackView = UIView()
        }
        
        updateBarAppearance()
        
        
        
        
        //添加中央按钮
        
        self.addSubview(centerButton)
        
        
        
    }
    
    
    private func updateBarAppearance(){
        if centerBackView == nil{
            centerBackView = UIView()
        }
        
        centerBackView!.backgroundColor = StyleConfig.Colors.container
        centerBackView!.layer.cornerRadius = centerButtonBackRadius
        //centerBackView.layer.borderColor = UIColor.black.cgColor
        //centerBackView.layer.borderWidth = 1
        
        let centerBackViewFrame = CGRect(origin: CGPoint(x: centerButton.center.x - centerButtonBackRadius, y: centerButton.center.y - centerButtonBackRadius), size: CGSize(width: centerButtonBackRadius*2, height: centerButtonBackRadius*2))
        centerBackView!.frame = centerBackViewFrame
        if centerBackView!.superview == nil{
            self.addSubview(centerBackView!)
        }
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = centerBackView!.bounds
        gradientLayer.colors = [strokeStartColor.cgColor,strokeEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0,0.6]

        let borderShapeLayer = CAShapeLayer()
        borderShapeLayer.borderWidth = centerButtonStrokeWidth
        borderShapeLayer.path = UIBezierPath(roundedRect: CGRect(x: centerButtonStrokeWidth, y: centerButtonStrokeWidth, width: gradientLayer.bounds.width-centerButtonStrokeWidth*2, height: gradientLayer.bounds.height-centerButtonStrokeWidth*2), cornerRadius: centerButtonBackRadius).cgPath
        borderShapeLayer.fillColor = UIColor.clear.cgColor
        borderShapeLayer.strokeColor = UIColor.white.cgColor
        
        gradientLayer.mask = borderShapeLayer
        
        centerBackView!.layer.sublayers?.removeAll()
        centerBackView!.layer.addSublayer(gradientLayer)


        
    }
    
    
    override func select(itemIndex: Int, animated: Bool) {
        let item = self.items![itemIndex]
        if selectedItem != item{
            
            if saDelegate != nil{
                let shouldJump = saDelegate?.tabBar?(tabBar: self, willSelect: itemIndex)
                if !(shouldJump ?? true){
                    return
                }
            }
            
            if let item = item as? CUTabBarItem{
                item.contentView.onSelect()
            }
            let lastItem = items![items!.firstIndex(of: self.selectedItem!)!]
            delegate?.tabBar?(self, didSelect: item)
            if let item = lastItem as? CUTabBarItem{
                item.contentView.onDeselect()
            }
        }
    }
    
    
    @objc private func onPress_center(){
        saDelegate?.tabBar?(tabBar: self, didPressCenter: centerButton)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBarAppearance()
        setupTheme()
    }
}
