//
//  CUAlertActionSheet.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/2/3.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

class CUAlertActionSheet: CUAlertTitlePopView {
    
    
    private var buttons:[UIButton] = []
    
    
    public func getButtons() -> [UIButton]{
        return self.buttons
    }
    
    public func getButton(at index:Int) -> UIButton?{
        guard index >= 0 && index < self.buttons.count else { return nil }
        return self.buttons[index]
    }
    
    override func layout(containerView: CUAlertContainer) {
        super.layout(containerView: containerView)
        
        buttons = []
        
        let cancelAction = actions.filter{ return $0.actionType == .Cancel }
        let defaultAction = actions.filter{ return $0.actionType == .Default }
        
        let contentHeight = getContentHeight()
        
        for (idx,action) in cancelAction.enumerated(){
            
            var but = UIButton()
            if idx == 0{
                but.frame = CGRect(x: 0, y: contentHeight-Config.buttonHeight, width: Config.width, height: Config.buttonHeight+BOTTOM_INSET)
                but.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: BOTTOM_INSET, right: 0)
            }
            else{
                but.frame = CGRect(x: 0, y: buttons.last!.frame.origin.y-Config.buttonHeight, width: Config.width, height: Config.buttonHeight)
            }
            
            if idx != cancelAction.count - 1 {
                let seperator = UIView()
                seperator.backgroundColor = Config.seperatorColor
                seperator.frame = CGRect(x: 0, y: 0, width: but.bounds.width, height: 1)
                but.addSubview(seperator)
            }
            
            setupButton(with: action, button: &but)
            
            but.tag = buttons.count + 1000
            action.tag = but.tag
            buttons.append(but)
            self.contentContainer!.addSubview(but)
        }
        
        
        
        for (idx,action) in defaultAction.enumerated(){
            var but = UIButton()
            if idx == 0{
                if cancelAction.count == 0{
                    but.frame = CGRect(x: 0, y: contentHeight-Config.buttonHeight, width: Config.width, height: Config.buttonHeight+BOTTOM_INSET)
                    but.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: BOTTOM_INSET, right: 0)
                }
                else{
                    
                    but.frame = CGRect(x: 0, y: buttons.last!.frame.origin.y-Config.buttonHeight-Config.sectionMargin, width: Config.width, height: Config.buttonHeight)
                }
            }
            else{
                but.frame = CGRect(x: 0, y: buttons.last!.frame.origin.y-Config.buttonHeight, width: Config.width, height: Config.buttonHeight)
            }
            
            if idx != defaultAction.count - 1 {
                let seperator = UIView()
                seperator.backgroundColor = Config.seperatorColor
                seperator.frame = CGRect(x: 0, y: 0, width: but.bounds.width, height: 1)
                but.addSubview(seperator)
            }
            
            setupButton(with: action, button: &but)

            but.tag = buttons.count + 1000
            action.tag = but.tag
            buttons.append(but)
            self.contentContainer!.addSubview(but)
        }
    }

    override func getContentHeight() -> CGFloat {
        
        let cancelAction = actions.filter{ return $0.actionType == .Cancel}
        let defaultAction = actions.filter{ return $0.actionType == .Default }
        
        var contentH:CGFloat = CGFloat(actions.count) * Config.buttonHeight
        contentH += cancelAction.count > 0 && defaultAction.count > 0 ? Config.sectionMargin : 0
        
        return contentH
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
        button.addTarget(self, action: #selector(CUAlertActionSheet.onPress_button(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(CUAlertActionSheet.onPressDown_button(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(CUAlertActionSheet.onDragOutside_button(_:)), for: .touchDragOutside)
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
