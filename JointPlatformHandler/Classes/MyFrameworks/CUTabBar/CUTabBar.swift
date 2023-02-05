//
//  CUTabBar.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/4/29.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUTabBar: UITabBar {
    
    public struct CUTabBarTheme{
        var backgroundColor:UIColor = StyleConfig.Colors.container
        //顶部分割线
        var topLine:Bool = false
        //顶部分割线颜色
        var topLineColor:UIColor = UIColor(white: 0.75, alpha: 1)
        //半透明
        var transparent:Bool = false
    }

    public override var delegate: UITabBarDelegate?{
        willSet{
            if let del = newValue as? CUTabBarDelegate{
                self.CUDelegate = del
            }
        }
    }
    
    
    public var theme:CUTabBarTheme = CUTabBarTheme()
    public var needCustomLayout:Bool = true
    public var edgeInsets:UIEdgeInsets = UIEdgeInsets.zero
    
    public var containers:[CUTabBarItemContainer] = []
    public weak var CUDelegate:CUTabBarDelegate?
    
    ///忽视下一次Layout，用来防止更改appearance导致的重复layoutSubviews
    private var ignoreNextLayout:Bool = false
    
    
    
    private var myTopSeperator:UIView = UIView()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //根据theme设置tabBar的外观
        setupTheme()
        //根据item的设置重新布局
        relayout()

    }
    
    func removeAll() {
        for container in containers {
            container.removeFromSuperview()
        }
        containers.removeAll()
    }
    
    func relayout(){
        
        //修复关闭后台程序会莫名其妙 调用这个方法，由于keyWindow已经是nil导致的错误
        //guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        guard UIApplication.shared.keyWindow != nil else { return }
        
        guard needCustomLayout else { return }
        guard let items = items else { return }
        guard items.count > 0 else { return }
        
        let buttons = self.subviews.filter{
            return $0.isKind(of: NSClassFromString("UITabBarButton")!)
        }.sorted(by: {
            return $0.frame.origin.x < $1.frame.origin.x
        })
        
        let containerWidth = self.bounds.width - self.edgeInsets.left - self.edgeInsets.right - self.itemSpacing * CGFloat(items.count - 1)
        let itemWidth = containerWidth / CGFloat(items.count)
        let itemHeight = self.bounds.height - self.edgeInsets.top - self.edgeInsets.bottom - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        
        removeAll()
        
        for (idx,view) in buttons.enumerated(){
            
            //通用设置
            //大位置
            let y = self.edgeInsets.top
            let x = self.edgeInsets.left + CGFloat(idx) * itemWidth + CGFloat(idx) * itemSpacing
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
        
    }
    
    func setupTheme(){
        
        if ignoreNextLayout == true{
            ignoreNextLayout = false
            return
        }

        
        if #available(iOS 13, *){
            let appearance = standardAppearance
            appearance.backgroundColor = theme.transparent ? UIColor.clear :theme.backgroundColor
            appearance.backgroundImage = nil
            appearance.shadowColor = nil
            appearance.shadowImage = nil
            standardAppearance = appearance
            ignoreNextLayout = true
        }
        else{
            backgroundImage = UIImage()
            shadowImage = UIImage()
        }
        
        if theme.topLine{
            if self.myTopSeperator.superview == nil{
                
                
                
                if self.subviews.count > 0{
                    self.insertSubview(myTopSeperator, belowSubview: subviews.first!)
                }
                else{
                    self.addSubview(myTopSeperator)
                }
            }
            myTopSeperator.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.5)
            myTopSeperator.backgroundColor = theme.topLineColor
        }
        else{
            if self.myTopSeperator.superview != nil{
                self.myTopSeperator.removeFromSuperview()
            }
        }
        
        
        self.isTranslucent = theme.transparent
        
    }
    

    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var b = super.point(inside: point, with: event)
        if !b {
            for container in containers {
                if container.point(inside: CGPoint.init(x: point.x - container.frame.origin.x, y: point.y - container.frame.origin.y), with: event) {
                    b = true
                }
            }
        }
        return b
    }

}


extension CUTabBar{

    @objc func selectAction(_ sender:Any){
        guard let container = sender as? CUTabBarItemContainer else { return }
        select(itemIndex: container.tag + 1000, animated: true)
    }
    
    @objc func select(itemIndex:Int, animated:Bool){
        let item = self.items![itemIndex]
        if selectedItem != item{
            
            if CUDelegate != nil{
                let shouldJump = CUDelegate?.tabBar?(tabBar: self, willSelect: itemIndex)
                if !(shouldJump ?? true){
                    return
                }
            }
            
            if let item = item as? CUTabBarItem{
                item.contentView.onSelect()
            }
            
            guard self.selectedItem != nil else { return }
            
            let lastItem = items![items!.firstIndex(of: self.selectedItem!)!]
            delegate?.tabBar?(self, didSelect: item)
            if let item = lastItem as? CUTabBarItem{
                item.contentView.onDeselect()
            }
        }
    }
    
}
