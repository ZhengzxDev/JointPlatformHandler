//
//  GameJoyStickDelegate.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

@objc
protocol GameJoyStickDelegate:NSObjectProtocol{
    
    ///当旋钮被移动时调用
    ///vector为方向向量
    ///offsetDegree为偏移程度(0~1之间)
    @objc optional func joyStick(knob:JoyStickKnob,onMoved  vector:CGVector,offsetDegree:CGFloat)
    
    @objc optional func joyStick(onButtonPressd button:JoyStickButton)
    
}
