//
//  CUTabBarItemContentView.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/4/30.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

@objc protocol CUTabBarItemContentViewDelegate:NSObjectProtocol{
    @objc optional func onSelect()
    @objc optional func onHighlight()
    @objc optional func onDeselect()
    @objc optional func ondDehighlight()
}

class CUTabBarItemContentView: UIView{

    public var renderingMode:UIImage.RenderingMode = .alwaysTemplate
    
    public lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    public lazy var imageView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    
    public lazy var redDotView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 3
        return view
    }()
    
    public var title:String?{
        didSet{
            titleLabel.text = title
        }
    }
    
    public var image:UIImage?{
        didSet{
            imageView.image = image
        }
    }
    
    public var hasRedDot:Bool = false{
        didSet{
            if hasRedDot{
                self.addSubview(redDotView)
                redDotView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.imageView)
                    make.right.equalTo(self.imageView).offset(5)
                    make.size.equalTo(CGSize(width: 6, height: 6))
                }
            }
            else{
                redDotView.removeFromSuperview()
            }
        }
    }
    
    public var selectedImage:UIImage?
    
    public var iconTintColor:UIColor =  UIColor(red: 68/255, green: 150/255, blue: 251/255, alpha: 1)//UIColor(red: 67/255, green: 96/255, blue: 207/255, alpha: 1)
    public var iconColor:UIColor = UIColor(white: 0.75, alpha: 1)
    
    public var selecedTitleColor:UIColor = UIColor.red
    public var unselectedTitleColor:UIColor = UIColor(white: 0.75, alpha: 1)
    
    public var imageSize:CGSize = CGSize(width: 25, height: 25)
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateLayout(){
        if var image = self.image{
            if self.renderingMode == .alwaysTemplate{
                image = image.withRenderingMode(.alwaysTemplate)
                self.imageView.tintColor = self.iconColor
            }
            if let text = self.title{
                imageView.image = image
                imageView.frame.size = imageSize
                let x:CGFloat = (self.bounds.width - imageView.bounds.width)/2
                let y:CGFloat = 5
                imageView.frame.origin = CGPoint(x: x, y: y)
                
                titleLabel.text = text
                titleLabel.sizeToFit()
                titleLabel.frame.origin.x = (self.bounds.width - titleLabel.bounds.width)/2
                titleLabel.frame.origin.y = imageView.frame.maxY + 3
            }
            else{
                imageView.image = image
                imageView.frame.size = imageSize
                let x:CGFloat = (self.bounds.width - imageView.bounds.width)/2
                let y:CGFloat = (self.bounds.height - imageView.bounds.height)/2
                imageView.frame.origin = CGPoint(x: x, y: y)
            }
            
        }
    }
}

extension CUTabBarItemContentView:CUTabBarItemContentViewDelegate{
    func onSelect() {
        imageView.tintColor = iconTintColor
        guard title != nil else { return }
        titleLabel.textColor = selecedTitleColor
    }
    func onDeselect() {
        imageView.tintColor = iconColor
        guard title != nil else { return }
        titleLabel.textColor = unselectedTitleColor
    }
}
