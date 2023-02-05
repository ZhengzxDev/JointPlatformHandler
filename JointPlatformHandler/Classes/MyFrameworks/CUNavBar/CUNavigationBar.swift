//
//  CUNavigationBar.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/5/4.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUNavigationBar: UINavigationBar{

    internal weak var barBackgroundView:UIView?
    
    public var contentInsets:UIEdgeInsets = UIEdgeInsets.zero
    public var contentView:UIView?{
        didSet{
            (contentView as? CUNavBarContentView)?.title = self.title
            if (contentView as? CUNavBarContentView)?.delegate == nil{
                (contentView as? CUNavBarContentView)?.delegate = self
            }
        }
    }
    public var contentViewHeight:CGFloat = 44
    
    public var title:String = ""{
        didSet{
            (contentView as? CUNavBarContentView)?.title = self.title
        }
    }
    
    public var hasSeperator:Bool = true{
        didSet{
            self.shadowImage = hasSeperator ? nil : UIImage()
        }
    }
    
    public var barBackgroundColor:UIColor = StyleConfig.Colors.container
    
    public override var isTranslucent: Bool{
        didSet{
            if isLaied {
                setupUI()
            }
        }
    }
    
    public var onPressLeft:(()->Void)?
    public var onPressRight:(()->Void)?

    
    private var autoManageSafeAreaInsets:Bool = true
    private var isLaied:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isTranslucent = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in self.subviews {
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = self.bounds
            } else if stringFromClass.contains("UINavigationBarContentView") {
                subview.frame = self.bounds
                if barBackgroundView == nil{
                    barBackgroundView = subview
                }
            }
        }
        if !isLaied{
            setupUI()
            isLaied = true
        }
    }
    
    internal func setupUI(){
        
        if isTranslucent{
            self.backgroundColor = UIColor.clear
            self.barBackgroundView?.backgroundColor = UIColor.clear
            setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            shadowImage = UIImage()
            barTintColor = UIColor.clear
        }
        else{
            self.backgroundColor = barBackgroundColor
            self.barBackgroundView?.backgroundColor = barBackgroundColor
        }
        
        guard contentView != nil else { return }
        self.barBackgroundView?.addSubview(contentView!)
        /*contentView!.snp.makeConstraints({ (make) in
            make.left.equalTo(contentInsets.left)
            make.right.equalTo(-contentInsets.right)
            make.bottom.equalTo(-contentInsets.bottom)
            make.height.equalTo(contentViewHeight)
        })*/
        
        if autoManageSafeAreaInsets{
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: statusBarHeight+contentViewHeight)
        }
        else{
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: contentViewHeight)
        }
        
        
        contentView!.frame = CGRect(x: 0, y: self.bounds.height - contentViewHeight, width: self.bounds.width, height: contentViewHeight)
        contentView!.frame.origin.x += contentInsets.left - contentInsets.right
        contentView!.frame.origin.y += contentInsets.top - contentInsets.bottom
        
        
        
    }
    
}


extension CUNavigationBar:CUNavBarContentDelegate{
    func navbarLeftButton(_ view: CUNavBarContentView, didSelect at: UIButton) {
        onPressLeft?()
    }
    func navbarRightButton(_ view: CUNavBarContentView, didSelect at: UIButton) {
        onPressRight?()
    }
}
