//
//  CUAlertMask.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/1/31.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit


class CUAlertContainer: UIView {
    
    public var tapCallback:(()->())?
    public var alertRef:CUAlert?
    public lazy var backdropView:UIView = UIView()
    
    private lazy var tapRec = UITapGestureRecognizer(target: self, action: #selector(CUAlertContainer.onTap))
    
    
    convenience init(ref:CUAlert){
        self.init(frame:CGRect.zero)
        alertRef = ref
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(){
        self.addSubview(backdropView)
        backdropView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func dispose(){
        alertRef = nil
    }
    
    func setup(){
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.backdropView.backgroundColor = UIColor(white: 0, alpha: 1)
        self.backdropView.addGestureRecognizer(tapRec)
        self.backdropView.isUserInteractionEnabled = true
    }

    @objc private func onTap(){
        
        tapCallback?()
    }
}
