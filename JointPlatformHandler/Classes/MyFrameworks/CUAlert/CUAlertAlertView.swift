//
//  CUAlertAlertView.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/1/31.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

class CUAlertAlertView: CUAlertBaseView {
    
    private struct Config{
        static let backgroundColor:UIColor = UIColor.white
        static let cornerRadius:CGFloat = 8
        static let titleFontSize:CGFloat = 14
        static let titleColor:UIColor = UIColor.black
        static let contentFontSize:CGFloat = 13
        static let contentColor:UIColor = UIColor.black
        static let buttonFontSize:CGFloat = 14
        static let seperatorColor:UIColor = UIColor(white: 0.93, alpha: 1)
        static let sideMargin:CGFloat = 50
        static let minHeight:CGFloat = 105
        static let titlePadding:UIEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 5, right: 0)
        static let contentPadding:UIEdgeInsets = UIEdgeInsets(top: 8, left: 30, bottom: 13, right: 30)
        static let buttonHeight:CGFloat = 50
        static let buttonColor:UIColor = UIColor.white
        static let buttonPressColor:UIColor = UIColor(white: 0.85, alpha: 1)
        static let seperatorStroke:CGFloat = 1
    }
    
    private var buttons:[UIButton] = []
    private var titleLabel:UILabel?
    private var contentLabel:UILabel?
    
    
    override func initialize(actions: [CUAlertAction], properties: inout CUAlert.Property) {
        properties.hideOnTouchMask = false
        super.initialize(actions: actions, properties: &properties)
    }
    
    

    override func layout(containerView:CUAlertContainer) {
        
        let _ = self.buttons.map{
            $0.removeFromSuperview()
        }
        
        buttons = []
        
        self.clipsToBounds = true
        self.backgroundColor = Config.backgroundColor
        self.layer.cornerRadius = Config.cornerRadius
        
        let maxWidth = SCREEN_WIDTH-2*Config.sideMargin
        let maxLabelWidth = maxWidth - Config.contentPadding.left - Config.contentPadding.right
        
        self.titleLabel?.removeFromSuperview()
        self.titleLabel = UILabel()
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.text = properties.title ?? "#Alert_Tips".localize()
        self.titleLabel?.font = UIFont.systemFont(ofSize: Config.titleFontSize, weight: .medium)
        let titleHeight = String.getHeight(self.titleLabel!.text!, width: maxWidth, font: self.titleLabel!.font)
        titleLabel!.frame = CGRect(x: 0, y: 0, width: maxWidth, height: titleHeight)
        titleLabel!.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel!.textColor = UIColor.black
    
        self.contentLabel?.removeFromSuperview()
        self.contentLabel = UILabel()
        self.contentLabel?.textAlignment = .center
        self.contentLabel!.font = UIFont.systemFont(ofSize: Config.contentFontSize,weight: .regular)
        self.contentLabel?.numberOfLines = 10
        self.contentLabel?.text = self.properties.content ?? ""
        self.contentLabel?.textColor = UIColor.black
        let contentHeight = max(15,String.getHeight(self.contentLabel!.text!, width: maxLabelWidth, font: self.contentLabel!.font))
        
        let frameHeight = max(Config.minHeight,titleHeight+contentHeight+Config.titlePadding.top+Config.titlePadding.bottom+Config.contentPadding.top+Config.contentPadding.bottom+Config.seperatorStroke+Config.buttonHeight)
        self.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-maxWidth)/2, y: (SCREEN_HEIGHT-frameHeight)/2), size: CGSize(width: maxWidth, height: frameHeight))
        
        
        self.addSubview(titleLabel!)
        self.addSubview(contentLabel!)
        
        titleLabel?.frame = CGRect(x: Config.titlePadding.left, y: Config.titlePadding.top, width: maxWidth-Config.titlePadding.left-Config.titlePadding.right, height: titleHeight)
        contentLabel?.frame = CGRect(x: Config.contentPadding.left, y: titleLabel!.frame.maxY+Config.titlePadding.bottom+Config.contentPadding.top, width: maxLabelWidth, height: contentHeight)
        
        
        
        if actions.count == 0 {
            self.actions.append(CUAlertAction(name: "#Alert_Confirm".localize(), action: { (alert) in
                alert.hide()
            }))
        }

        let topSeperator = UIView()
        topSeperator.backgroundColor = Config.seperatorColor
        topSeperator.frame = CGRect(x: 0, y: contentLabel!.frame.maxY+Config.contentPadding.bottom+1, width: maxWidth, height: Config.seperatorStroke)
        self.addSubview(topSeperator)
        
        let butWidth:CGFloat = maxWidth/CGFloat(actions.count)
        for (idx,action) in actions.reversed().enumerated(){
            var but = UIButton()
            
            let startX:CGFloat = (buttons.count > 0) ? buttons.last!.frame.maxX : 0
            but.frame = CGRect(x: startX, y: topSeperator.frame.maxY, width: butWidth, height: Config.buttonHeight)
            setupButton(with: action, button: &but)
            
            but.tag = buttons.count + 1000
            action.tag = but.tag
            buttons.append(but)
            self.addSubview(but)
            
            if idx != actions.count-1 {
                let seperator = UIView()
                seperator.backgroundColor = Config.seperatorColor
                seperator.frame = CGRect(x: but.frame.width-1, y: 0, width: 1, height: Config.buttonHeight)
                but.addSubview(seperator)
            }
        }
    }
    
    
    
    override func present(containerView:CUAlertContainer) {
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        containerView.backdropView.alpha = 0
        UIView.animate(withDuration: 0.25) {
            [weak self] in
            containerView.backdropView.alpha = 0.4
            self?.alpha = 1
            self?.transform = CGAffineTransform.identity
        }
    }
    
    
    override func hide(containerView:CUAlertContainer,completion:@escaping (() -> Void)) {
        UIView.animate(withDuration: 0.25) {
            [weak self] in
            containerView.alpha = 0
            self?.alpha = 0
            self?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        } completion: { (_) in
            super.hide(containerView:containerView,completion: completion)
        }

    }
    
    
    private func setupButton(with action:CUAlertAction,button:inout UIButton){
        if action.textAttribute.count > 0{
            let attrString:NSAttributedString = NSAttributedString(string: action.actionName, attributes: action.textAttribute)
            button.setAttributedTitle(attrString, for: .normal)
        }
        else{
            button.setTitle(action.actionName, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15,weight: .medium)
        }
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Config.buttonColor
        button.addTarget(self, action: #selector(CUAlertAlertView.onPress_button(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(CUAlertAlertView.onPressDown_button(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(CUAlertAlertView.onDragOutside_button(_:)), for: .touchDragOutside)
    }
    
    
    
    
    @objc
    private func onPress_button(_ sender:UIButton){
        let targetAction = actions.filter{ $0.tag == sender.tag }
        guard targetAction.count > 0 else { return }
        performer?.doAction(with: targetAction.first!)
        sender.backgroundColor = Config.buttonColor
    }
    
    @objc
    private func onPressDown_button(_ sender:UIButton){
        sender.backgroundColor = UIColor(white: 0.91, alpha: 1)
    }
    
    @objc
    private func onDragOutside_button(_ sender:UIButton){
        sender.backgroundColor = Config.buttonColor
    }
    

}
