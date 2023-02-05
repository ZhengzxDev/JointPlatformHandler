//
//  HolderView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/7.
//

import UIKit

class HolderView:UIView,NibLoadable{
    
    private let contentTintColor:UIColor = UIColor(r: 233, g: 233, b: 233, a: 1)
    
    private var contentView:UIView?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = loadFromNib()
        self.addSubview(contentView!)
        contentView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.contentView?.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.titleLabel.textColor = contentTintColor
        self.imageView.backgroundColor = UIColor.clear
        self.imageView.tintColor = contentTintColor
        
        imageViewTopConstraint.constant = SCREEN_HEIGHT/4
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func display(title:String,imageName:String? = nil){
        self.titleLabel.text = title
        guard imageName != nil else { return }
        imageView.image = UIImage(named: imageName!)
    }
    
}
