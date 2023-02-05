//
//  GameJoyStick.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit


class GameJoyStick:NSObject{
    
    enum Orientation{
        case Landscape
        case Portrait
    }
    
    var components:[JoyStickComponent] = []
    
    weak var controller:JoyStickController?
    
    func getOrientation() -> Orientation{
        return Orientation.Landscape
    }
    
    
    func getView(registeredButtonsMap:[String:Any]) -> UIView{
        return UIView()
    }
    
    
    
}
