//
//  CUAlertDragPopView.swift
//  schoolAirdrop2.0
//
//  Created by luckyXionzz on 2021/5/2.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

class CUAlertDragPopView: CUAlertPopView {
    
    private let dragHandleHeight:CGFloat = 5
    private let dragHandleWidth:CGFloat = 35
    private let dragHandleInsets:UIEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 5, right: 0)
    ///最大上拉补偿
    private let dragOffset:CGFloat = 30
    
    private var panRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var panStartFrame:CGRect?
    private var initFrame:CGRect = CGRect.zero
    
    private var dragHandleView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.6, alpha: 1)
        view.layer.cornerRadius = 3
        return view
    }()
    
    override func initialize(actions: [CUAlertAction], properties: inout CUAlert.Property) {
        super.initialize(actions: actions, properties: &properties)
        panRecognizer.addTarget(self, action: #selector(onPan(_:)))
        self.addGestureRecognizer(panRecognizer)
    }
    
    

    override func layout(containerView: CUAlertContainer) {
        
        self.backgroundColor = Config.backgroundColor
        self.clipsToBounds = true
        self.layer.cornerRadius = Config.cornerRadius
        
        let _ = self.subviews.map{
            $0.removeFromSuperview()
        }
        
        
        let contentHeight = getContentHeight()
        //                                 隐藏下圆角。          底部空白补充
        frameHeight = contentHeight + Config.cornerRadius + BOTTOM_INSET + dragHandleHeight + dragHandleInsets.top + dragHandleInsets.bottom + dragOffset
        
        self.addSubview(dragHandleView)
        dragHandleView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(dragHandleInsets.top)
            make.height.equalTo(dragHandleHeight)
            make.width.equalTo(dragHandleWidth)
        }
        
        
        
        contentContainer = UIView()
        contentContainer!.frame = CGRect(x: 0, y: dragHandleHeight + dragHandleInsets.top + dragHandleInsets.bottom, width: Config.width, height: contentHeight)
        contentContainer!.backgroundColor = Config.contentBackColor
        self.addSubview(contentContainer!)
        
        layoutPopViewContent()
        
        self.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview().offset(dragOffset)
            make.height.equalTo(frameHeight)
            make.centerX.equalToSuperview()
            make.width.equalTo(Config.width)
        }
        
        initFrame = CGRect(x: 0, y: SCREEN_HEIGHT - frameHeight + Config.cornerRadius + dragOffset, width: Config.width, height: frameHeight)
        
    }
    
    
    @objc private func onPan(_ recognizer:UIPanGestureRecognizer){
        
        let offset = recognizer.translation(in: self)
        switch recognizer.state{
        case .began:
            panStartFrame = self.frame
            break
        case .changed:
            if offset.y > 0{
                //向下
                self.frame = panStartFrame!.offsetBy(dx: 0, dy: offset.y)
            }
            else{
                //向上
                
                //还能上拉
                let nextFrame = panStartFrame!.offsetBy(dx: 0, dy: offset.y)
                if nextFrame.origin.y > initFrame.origin.y - dragOffset{
                    self.frame = nextFrame
                }
                else{
                    self.frame = initFrame.offsetBy(dx: 0, dy: -dragOffset)
                }
            }
            
            break
        case .ended:
            UIView.animate(withDuration: 0.1) {
                [weak self] in
                guard let strongSelf = self else { return }
                self?.frame = strongSelf.panStartFrame!
            }
            break
        default:
            break
        }
        
    }

}
