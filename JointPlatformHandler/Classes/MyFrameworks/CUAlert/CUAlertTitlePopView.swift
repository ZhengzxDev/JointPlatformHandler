//
//  CUAlertActionSheet.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/2/2.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

class CUAlertTitlePopView: CUAlertBaseView {
    
    public struct Config{
        static let backgroundColor:UIColor = UIColor.white
        static let cornerRadius:CGFloat = 8
        static let titleFontSize:CGFloat = 14
        static let titleColor:UIColor = UIColor.black
        static let contentFontSize:CGFloat = 12
        static let contentColor:UIColor = UIColor.black
        static let buttonFontSize:CGFloat = 14
        static let seperatorColor:UIColor = UIColor(white: 0.93, alpha: 1)
        static let titlePadding:UIEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        static let contentPadding:UIEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 10, right: 30)
        static let buttonHeight:CGFloat = 50
        static let buttonColor:UIColor = UIColor.white
        static let buttonPressColor:UIColor = UIColor(white: 0.85, alpha: 1)
        static let seperatorStroke:CGFloat = 1
        static let sectionMargin:CGFloat = 8
        static let titleBackColor:UIColor = UIColor.white
        static let width:CGFloat = SCREEN_WIDTH
        static let contentBackColor:UIColor = UIColor(white: 0.93, alpha: 1)
    }
    
    private var titleLabel:UILabel?
    private var contentLabel:UILabel?
    
    public var frameHeight:CGFloat = 0
    public var titleContainer:UIView?
    public var contentContainer:UIView?
    
    override func initialize(actions: [CUAlertAction], properties: inout CUAlert.Property) {
        properties.hideOnTouchMask = true
        super.initialize(actions: actions, properties: &properties)
    }

    override func layout(containerView: CUAlertContainer) {
        
        
        self.backgroundColor = Config.backgroundColor
        self.clipsToBounds = true
        self.layer.cornerRadius = Config.cornerRadius
        
        let _ = self.subviews.map{
            $0.removeFromSuperview()
        }
        
        
        let contentHeight = getContentHeight()
        //                                 隐藏下圆角。          底部空白补充
        frameHeight = contentHeight + Config.cornerRadius + BOTTOM_INSET
        
        if let title = properties.title{
            
            titleContainer = UIView()
            titleContainer!.backgroundColor = Config.titleBackColor
            
            self.titleLabel = UILabel()
            self.titleLabel?.numberOfLines = 0
            self.titleLabel?.font = UIFont.systemFont(ofSize: Config.titleFontSize)
            self.titleLabel?.textColor = Config.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.backgroundColor = UIColor.clear
            self.titleLabel?.text = title
            
            let titleHeight = String.getHeight(title, width: Config.width, font: self.titleLabel!.font)
            
            let labelHeight = titleHeight + Config.titlePadding.top + Config.titlePadding.bottom
            let labelWidth = Config.width - Config.titlePadding.left - Config.titlePadding.right
            frameHeight += labelHeight
            
            
            titleLabel?.frame = CGRect(x: (Config.width-labelWidth)/2, y: 0, width: labelWidth, height: labelHeight)
            titleContainer!.frame = CGRect(x: 0, y: 0, width: Config.width, height: labelHeight)
            titleContainer!.addSubview(self.titleLabel!)
            self.addSubview(titleContainer!)
            
            
            
            let seperator = UIView()
            seperator.backgroundColor = Config.seperatorColor
            seperator.frame = CGRect(x: 0, y: labelHeight - 1, width: Config.width, height: 1)
            titleContainer!.addSubview(seperator)
            
            
        }
        
        contentContainer = UIView()
        contentContainer!.frame = CGRect(x: 0, y: titleContainer?.frame.maxY ?? 0, width: Config.width, height: contentHeight)
        contentContainer!.backgroundColor = Config.contentBackColor
        self.addSubview(contentContainer!)
        
        self.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(frameHeight)
            make.centerX.equalToSuperview()
            make.width.equalTo(Config.width)
        }
        
        
    }
    
    override func present(containerView: CUAlertContainer) {

        containerView.backdropView.alpha = 0
        self.transform = CGAffineTransform(translationX: 0, y: frameHeight)
        UIView.animate(withDuration: 0.25) {
            [weak self] in
            containerView.backdropView.alpha = 0.4
            self?.transform = CGAffineTransform(translationX: 0, y:Config.cornerRadius)
        }
    }
    
    override func hide(containerView:CUAlertContainer,completion: @escaping (() -> Void)) {
        
        UIView.animate(withDuration: 0.25) {
            [weak self] in
            guard let strongSelf = self else { return }
            containerView.alpha = 0
            self?.transform = CGAffineTransform(translationX: 0, y: strongSelf.frameHeight)
        } completion: { (_) in
            super.hide(containerView: containerView,completion: completion)
        }

        
    }
    
    public func getContentHeight() ->CGFloat{
        return 200
    }

}
