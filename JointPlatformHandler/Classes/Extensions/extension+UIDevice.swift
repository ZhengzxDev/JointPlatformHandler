//
//  extension+UIDevice.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/5/3.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

extension UIDevice{
    public func isIPhoneXMore() -> Bool
    {
        var isMore:Bool = false
        if #available(iOS 11.0, *)
        {
            isMore = (UIApplication.shared.windows.first!.safeAreaInsets.bottom) > CGFloat(0)
            
        }
        return isMore
    }
}
