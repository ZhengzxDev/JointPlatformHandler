//
//  CUNavBarContentView.swift
//  noSkip
//
//  Created by 郑正雄 on 2020/5/7.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUNavBarContentView: UIView {

    public lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    public lazy var leftButton:UIButton = {
        let button = UIButton()
        button.tag = 999
        button.addTarget(self, action: #selector(CUNavBarContentView.onPress_button(_:)), for: .touchUpInside)
        return button
    }()
    
    public lazy var rightButton:UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(CUNavBarContentView.onPress_button(_:)), for: .touchUpInside)
        button.tag = 1000
        return button
    }()
    
    public weak var delegate:CUNavBarContentDelegate?
    public var title:String?{
        didSet{
            titleLabel.text = title
        }
    }
    public var rightButtonMargin:CGFloat = 0
    public var leftButtonMargin:CGFloat = 0
    
    public var rightButtonSize:CGSize = CGSize.zero
    public var leftButtonSize:CGSize = CGSize.zero
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if title != nil{
            self.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        if rightButtonSize != CGSize.zero{
            self.addSubview(rightButton)
            rightButton.snp.makeConstraints { (make) in
                make.right.equalTo(-rightButtonMargin)
                make.size.equalTo(rightButtonSize)
                make.centerY.equalToSuperview()
            }
        }
        if leftButtonSize != CGSize.zero{
            self.addSubview(leftButton)
            leftButton.snp.makeConstraints { (make) in
                make.left.equalTo(leftButtonMargin)
                make.size.equalTo(leftButtonSize)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    @objc private func onPress_button(_ sender:UIButton){
        switch sender.tag {
        case 999:
            delegate?.navbarLeftButton?(self, didSelect: leftButton)
        default:
            delegate?.navbarRightButton?(self, didSelect: rightButton)
        }
    }
}


@objc protocol CUNavBarContentDelegate {
    @objc optional func navbarRightButton(_ view:CUNavBarContentView, didSelect at:UIButton)
    @objc optional func navbarLeftButton(_ view:CUNavBarContentView, didSelect at:UIButton)
}
