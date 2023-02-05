//
//  CUAlertPopView.swift
//  schoolAirdrop2.0
//
//  Created by luckyXionzz on 2021/5/2.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

class CUAlertPopView: CUAlertBaseView {

    public struct Config{
        static let backgroundColor:UIColor = UIColor.white
        static let cornerRadius:CGFloat = 8

        static let contentPadding:UIEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 10, right: 30)

        static let width:CGFloat = SCREEN_WIDTH
        static let contentBackColor:UIColor = UIColor(white: 1, alpha: 1)
    }
    
    public var frameHeight:CGFloat = 0
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
        
        
        
        contentContainer = UIView()
        contentContainer!.frame = CGRect(x: 0, y: 0, width: Config.width, height: contentHeight)
        contentContainer!.backgroundColor = Config.contentBackColor
        self.addSubview(contentContainer!)
        
        layoutPopViewContent()
        
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
    
    
    public func layoutPopViewContent(){
        
    }
    
    public func getContentHeight() ->CGFloat{
        return 200
    }
}


extension CUAlertPopView:CUAlertCustomPresentSource{
    func customPresentView() -> CUAlertBaseView {
        return self
    }
    
    
}
