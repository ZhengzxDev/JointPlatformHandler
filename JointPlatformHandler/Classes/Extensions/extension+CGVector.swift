//
//  extension+CGVector.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/9.
//

import UIKit

extension CGVector{
    
    
    ///获取单位向量
    var normalized:CGVector{
        get{
            guard self != CGVector.zero else { return CGVector.zero }
            let length = sqrt(self.dx*self.dx+self.dy*self.dy)
            return CGVector(dx: self.dx/length, dy: self.dy/length)
        }
    }
    
}
