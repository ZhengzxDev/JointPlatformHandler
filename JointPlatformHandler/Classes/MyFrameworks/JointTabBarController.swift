//
//  JointTabBarController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/5.
//

import UIKit


class JointTabBarController: CUTabBarController {
    
    override var selectedIndex: Int{
        didSet{
            if lastSelectedIndex != self.selectedIndex{
                lastSelectedIndex = oldValue
            }
        }
    }
    
    private var lastSelectedIndex:Int?
    private var isRollBack:Bool = false
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tabBar = { () -> CUTabBar in
            let tabBar = CUTabBar()
            tabBar.delegate = self
            return tabBar
        }()
        self.setValue(tabBar, forKey: "tabBar")
        selectedIndex = 0
        
        
        addViewController(LobbyViewController(), img: "tabBar_lobby")
        addViewController(SettingViewController(),img:"tabBar_setting")
        setupTabBarTheme()
        
        
        self.delegate = self
        self.enableHijack = false

    }
    
    
    public func setTabBarVisible(_ value:Bool,animated:Bool){
        
        for view in self.view.subviews{
            if view.isKind(of: UITabBar.self){
                if animated{
                    
                    if value {
                        self.tabBar.isHidden = !value
                    }
                    
                    UIView.animate(withDuration: 0.15) {
                        view.frame = CGRect(x: view.frame.origin.x, y: value ? SCREEN_HEIGHT - view.frame.height : SCREEN_HEIGHT, width: view.frame.width, height: view.frame.height)
                    } completion: { (_) in
                        self.tabBar.isHidden = !value
                    }

                }
                else{
                    view.frame = CGRect(x: view.frame.origin.x, y: value ? SCREEN_HEIGHT - view.frame.height : SCREEN_HEIGHT, width: view.frame.width, height: view.frame.height)
                    self.tabBar.isHidden = !value
                }
                break
            }
        }
    }
    
    

    
    public func rollBackViewController(){
        guard lastSelectedIndex != nil else {
            return
        }
        isRollBack = true
        self.selectedIndex = lastSelectedIndex!
    }
    


    

    private func setupTabBarTheme(){
        var tabBarTheme = CUTabBar.CUTabBarTheme()
        tabBarTheme.backgroundColor = StyleConfig.Colors.container
        tabBarTheme.topLine = false
        tabBarTheme.transparent = false
        if #available(iOS 13, *){
            tabBarTheme.topLineColor = UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark{
                    return UIColor(white: 0.25, alpha: 1)
                }
                else{
                    return UIColor(white: 0.85, alpha: 1)
                }
            }
        }
        else{
            tabBarTheme.topLineColor = UIColor(white: 0.85, alpha: 1)
        }
        let tabBar = self.tabBar as! CUTabBar
        tabBar.edgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        tabBar.itemSpacing = 5
        tabBar.theme = tabBarTheme
        
    }
    
    
    
    private func addViewController(_ vc:UIViewController,img:String? = nil,selectedImg:String? = nil,navBased:Bool? = true,rendererMode:UIImage.RenderingMode = .alwaysTemplate){
        let contentView = CUTabBarItemContentView(frame: CGRect.zero)//MYTabBarItemContentView(frame: CGRect.zero)
        contentView.renderingMode = rendererMode
        let item = CUTabBarItem(contentView: contentView,title: nil, image: nil, selectedImage: nil)
        
        if let img = img,let image = UIImage(named: img) {
            item.image = image
        }
        if let img = selectedImg,let image = UIImage(named: img){
            item.selectedImage = image
        }
        
        vc.tabBarItem = item
        
        if navBased ?? true{
            let navWrapper = UINavigationController()
            navWrapper.viewControllers = [vc]
            
            self.addChild(navWrapper)
        }
        else{
            self.addChild(vc)
        }
    }

    
    override func willSelect(at index: Int) -> Bool {
        return true
    }

    
    /*override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupTabBarTheme()
    }*/
    
}




extension JointTabBarController:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if !isRollBack{
            return nil//CUTabTransAnimator()
        }
        else{
            isRollBack = false
            return nil
        }
    }
}

extension JointTabBarController{
    
    /*@objc
    private func onNetworkStateChanged(){
        if Client.instance.connectMode == .Lan{
            NetworkStateListener.default.connection != .wifi{
                //network offline
                if self.selectedIndex == 0{
                    let navController = self.children.first as? UINavigationController
                    if navController?.topViewController != navController?.viewControllers.first{
                        navController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }*/
    
}
