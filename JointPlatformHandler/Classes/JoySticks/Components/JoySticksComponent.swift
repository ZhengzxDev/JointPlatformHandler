//
//  JoySticksComponents.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

// MARK: - JoyStickComponent

protocol JoyStickComponent:NSObjectProtocol{
    
    ///用于区分不同Component使用
    var comTag:Int! { get set }
    
    ///用于在配置阶段配置和tag的映射
    var configName:String! { get set }
    
    ///默认大小
    var defaultSize:CGSize { get }
    
    ///最大放大比例
    var maxSizeMultiper:CGFloat { get }
    
    ///布局描述
    var layoutDescription:String { get set }
    
    ///额外数据
    var attachedDatas:[String:Any] { get set }
    
    var typeString:String { get }
    
    func getView() -> UIView
    
    func initialize(_ layoutView:JoyStickLayoutView)
    
    func setDelegate(_ target:GameJoyStickDelegate)
    
    func setRatio(_ value:CGFloat)
    
    func setEnable(_ value:Bool)
    
}


