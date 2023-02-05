//
//  CUTabBarController.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/4/29.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

@objc
protocol CUTabBarControllerDelegate:NSObjectProtocol{
    @objc optional func cuTabBarController(_ controller:CUTabBarController, hijackAt index:Int,completionHandler:@escaping (()->Void),rejectHandler:@escaping (()->Void))
    @objc optional func cuTabbarController(hijackIndexFor controller:CUTabBarController) -> [Int]
}

class  CUTabBarController: UITabBarController {
    
    ///拦截完成条件后是否自动跳转
    public var shouldAutoSelect:Bool = true
    ///开启条件拦截
    public var enableHijack:Bool = false
    private var ignoreNextHijack:Bool = false
    public weak var cuDelegate:CUTabBarControllerDelegate?
    
    fileprivate var ignoreNextSelection:Bool = false
    
    override var selectedIndex: Int{
        willSet{
            guard !ignoreNextSelection else {
                ignoreNextSelection = false
                return
            }
            guard let tabBar = self.tabBar as? CUTabBar, let items = tabBar.items else {
                return
            }
            let value = (newValue > items.count - 1) ? items.count - 1 : newValue
            tabBar.select(itemIndex: value, animated: false)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = { () -> CUTabBar in
            let tabBar = CUTabBar()
            tabBar.delegate = self
            return tabBar
        }()
        self.setValue(tabBar, forKey: "tabBar")
        selectedIndex = 0
    }
    
}

extension CUTabBarController:CUTabBarDelegate{
    func tabBar(tabBar: CUTabBar, willSelect index: Int) -> Bool {
        
        if enableHijack{
            
            guard let indexArray = cuDelegate?.cuTabbarController?(hijackIndexFor: self) else { return willSelect(at: index) }
            if indexArray.contains(index){
                guard !ignoreNextHijack else {
                    self.ignoreNextHijack = false
                    return willSelect(at: index)
                }
                //满足条件则跳转
                guard (cuDelegate?.cuTabBarController?(self, hijackAt: index, completionHandler: {
                    [weak self] in
                    guard let strongSelf = self else { return }
                    self?.ignoreNextHijack = true
                    guard strongSelf.shouldAutoSelect else {
                        strongSelf.shouldAutoSelect = true
                        return
                    }
                    self?.selectedIndex = index
                },rejectHandler:{
                    [weak self] in
                    self?.ignoreNextHijack = false
                })) != nil else { return willSelect(at: index) }
                return false
            }
            else{
                return willSelect(at: index)
            }
            
        }
        
       return willSelect(at: index)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item) else {
            return;
        }
        if let vc = viewControllers?[idx] {
            ignoreNextSelection = true
            selectedIndex = idx
            delegate?.tabBarController?(self, didSelect: vc)
        }
    }
    
    @objc
    func willSelect(at index:Int)->Bool{
        return true
    }
    
    
    
    
}




