//
//  JotStickComponentSizePopView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/24.
//

import UIKit

protocol JoyStickComponentSizePopViewDelegate:NSObjectProtocol{
    
    func componentSizePopView(_ view:JoyStickComponentSizePopView,didDragBarWith progress:CGFloat)
    
}

class JoyStickComponentSizePopView:CUAlertPopView{
    
    private lazy var dragDot:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220, a: 1)
        view.layer.cornerRadius = dragDotSize.height/2
        return view
    }()
    
    private var dragBar:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(r: 100, g: 100, b: 100, a: 1)
        return view
    }()
    
    private var panRec:UIPanGestureRecognizer?
    
    private let dragBarSize:CGSize = CGSize(width: 250, height: 10)
    
    private let dragDotSize:CGSize = CGSize(width: 30, height: 30)
    
    private var minX:CGFloat = 0
    
    private var maxX:CGFloat = 0
    
    private var xDistance:CGFloat = 0
    
    private var yValue:CGFloat = 0
    
    private var touchXOffset:CGFloat = 0
    
    private var defaultProgress:CGFloat = 0
    
    weak var delegate:JoyStickComponentSizePopViewDelegate?
    
    
    override func getContentHeight() -> CGFloat {
        return 100
    }
    
    override func layoutPopViewContent() {
        self.contentContainer!.addSubview(dragBar)
        self.contentContainer!.addSubview(dragDot)
        dragBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(dragBarSize)
        }
        if panRec != nil{
            panRec?.removeTarget(self, action: #selector(onPanDot(_:)))
            dragDot.removeGestureRecognizer(panRec!)
        }
        panRec = UIPanGestureRecognizer(target: self, action: #selector(onPanDot(_:)))
        dragDot.addGestureRecognizer(panRec!)
        dragDot.isUserInteractionEnabled = true
        minX = ( self.contentContainer!.frame.width - self.dragBarSize.width - dragDotSize.width)/2
        maxX = ( self.contentContainer!.frame.width + self.dragBarSize.width - dragDotSize.width)/2
        xDistance = maxX - minX
        yValue = (self.contentContainer!.frame.height - self.dragDotSize.height)/2
        dragDot.frame = CGRect(x: minX + defaultProgress * xDistance, y: yValue, width: dragDotSize.width, height: dragDotSize.height)
    }
    
    func setDefaultProgress(_ value:CGFloat){
        assert(value >= 0 && value <= 1)
        self.defaultProgress = value
    }
    
    
    @objc private func onPanDot(_ rec:UIPanGestureRecognizer){
        let location = rec.location(in: self)
        if rec.state == .began{
            touchXOffset = location.x - dragDot.frame.origin.x
        }
        else if rec.state == .changed{
            
            
            var fixedX = max(minX,location.x - touchXOffset)
            fixedX = min(maxX,fixedX)
            dragDot.frame = CGRect(x:fixedX, y: yValue, width: dragDotSize.width, height: dragDotSize.height)
            
            delegate?.componentSizePopView(self, didDragBarWith: (fixedX - minX) / xDistance )
            
        }
    }
    
}
