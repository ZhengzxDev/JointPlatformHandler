//
//  JtNavigationBar.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

class JtNavigationBar:CUNavigationBar{


    private lazy var navbarContentView:JtNavigationView = {
        let view = JtNavigationView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override var title: String{
        didSet{
            navbarContentView.titleLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = navbarContentView
        contentViewHeight = 50
        barBackgroundColor = UIColor.white
        isTranslucent = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI(){
        super.setupUI()
        hasSeperator = false
        
    }
    
    
    public func setDelegate(_ target:JtNavigationViewDelegate){
        self.navbarContentView.delegate = target
    }
    
    
}

