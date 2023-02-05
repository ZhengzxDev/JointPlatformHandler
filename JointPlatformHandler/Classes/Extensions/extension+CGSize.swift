//
//  extension+CGSize.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/24.
//

import UIKit
extension CGSize{
    
    static func * (left:Double,right:CGSize) -> CGSize{
        return CGSize(width: right.width * left, height: right.height * left)
    }
    
    static func * (left:CGSize,right:Double) -> CGSize{
        return CGSize(width: right * left.width, height: right * left.height)
    }
    
}
