//
//  CUTabBarItem.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/4/29.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUTabBarItem: UITabBarItem {
    
    public var alwaysAlignCenter:Bool = true
    public var contentOffset:UIOffset = UIOffset.zero
    
    public var contentView:CUTabBarItemContentView = CUTabBarItemContentView()
    
    convenience init(contentView:CUTabBarItemContentView,title:String? = nil,image:UIImage? = nil,selectedImage:UIImage? = nil){
        self.init(contentView:contentView)
        self.image = image
        self.title = title
        self.selectedImage = selectedImage
    }
    
    init(contentView:CUTabBarItemContentView){
        super.init()
        self.contentView = contentView
    }
    
    override var selectedImage: UIImage?{
        didSet{
            contentView.selectedImage = selectedImage
        }
    }
    
    override var image: UIImage?{
        didSet{
            contentView.image = image
        }
    }
    
    override var title: String?{
        didSet{
            contentView.title = title
        }
    }
    
    override init() {
        super.init()
        self.contentView = CUTabBarItemContentView()
    }   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


