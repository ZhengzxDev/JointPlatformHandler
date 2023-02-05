//
//  CUTabBarDelegate.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/7/15.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit


@objc
protocol CUTabBarDelegate:UITableViewDelegate {
    @objc
    optional func tabBar(tabBar:CUTabBar, willSelect index:Int)->Bool
}
