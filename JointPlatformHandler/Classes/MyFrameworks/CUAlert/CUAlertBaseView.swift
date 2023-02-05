//
//  CUAlertBaseView.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/1/31.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit


protocol CUAlertActionPerformer:NSObjectProtocol{
    func doAction(with action:CUAlertAction)
}

protocol CUAlertBaseProperty:NSObjectProtocol{
    
    //初始化
    func initialize(actions:[CUAlertAction],properties:inout CUAlert.Property)
    //布局
    func layout(containerView:CUAlertContainer)
    //视图
    func view() -> UIView
    //显示
    func present(containerView:CUAlertContainer)
    //隐藏
    func hide(containerView:CUAlertContainer,completion:@escaping (()->Void))
    //更新
    func update(actions:[CUAlertAction],properties:inout CUAlert.Property)
    //释放
    func dispose()
}




class CUAlertBaseView: UIView,CUAlertBaseProperty {
    
    
    var performer:CUAlertActionPerformer?
    var actions:[CUAlertAction] = []
    var properties:CUAlert.Property!
    
    func initialize(actions: [CUAlertAction], properties: inout CUAlert.Property) {
        self.actions = actions
        self.properties = properties
    }
    
    func  view() -> UIView {
        return self
    }
    
    func layout(containerView:CUAlertContainer){
        
    }
    
    func present(containerView:CUAlertContainer) {
        
    }
    
    func hide(containerView:CUAlertContainer,completion:@escaping (()->Void)){
        completion()
    }
    
    func update(actions:[CUAlertAction],properties:inout CUAlert.Property){
        
    }
    
    func dispose() {
        self.performer = nil
    }
    
}


