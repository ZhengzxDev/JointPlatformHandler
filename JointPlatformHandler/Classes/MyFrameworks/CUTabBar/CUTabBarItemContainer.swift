//
//  CUTabBarItemContainer.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/4/30.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUTabBarItemContainer: UIControl {

    
    init(target:Any,tag:Int){
        super.init(frame: CGRect.zero)
        self.addTarget(target, action: #selector(CUTabBar.selectAction(_:)), for: .touchUpInside)
        //self.addTarget(target, action: #selector(CUTabBar.deselectAction(_:)), for: .touchUpInside)
        //self.addTarget(self, action: #selector(CUTabBarItemContainer.shit), for: .touchUpInside)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.tag = tag
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    internal override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var b = super.point(inside: point, with: event)
        if !b {
            for subview in self.subviews {
                if subview.point(inside: CGPoint.init(x: point.x - subview.frame.origin.x, y: point.y - subview.frame.origin.y), with: event) {
                    b = true
                }
            }
        }
        return b
    }
    


}
