//
//  CUAlertHUD.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/2/23.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit





class CUAlertHUD:CUAlertBaseView{
    
    enum HUDType{
        case success
        case loading
        case error
        case progress
    }
    
    
    public static var isHudPresenting:Bool{
        get{
            return Self._isHudPresenting
        }
    }
    
    private static var _isHudPresenting:Bool = false
    
    private static let shared:CUAlert  = {
        let alert = CUAlert(type: .Custom)
        alert.presentSource = CUAlertHUD.instance()
        return alert
    }()
    
    private static var shardHud:CUAlertHUD?
    
    private static var hudType:HUDType = .loading
    
    private struct Config{
        var backgroundColor:UIColor = UIColor.white
        var animDuration:Double = 0.25
        var cornerRadius:CGFloat = 10
        var sideMargin:CGFloat = 20
    }
    
    private var _hudType:HUDType?
    private var hudView:CUAlertHUDBaseView?
    
    private var isLayout:Bool = false
    private var config:Config = Config()
    
    
    
    private var limitRect:CGRect{
        get{
            return CGRect(x: config.sideMargin, y: 0, width: SCREEN_WIDTH-2*config.sideMargin, height: SCREEN_HEIGHT)
        }
    }
    
    fileprivate static func instance() -> CUAlertHUD{
        if Self.shardHud == nil{
            Self.shardHud = CUAlertHUD()
        }
        return Self.shardHud!
    }
    
    
    public static func display(title:String? = nil,value:CGFloat? = nil,type:HUDType = .loading,duration:Double = 0){
        CUAlertHUD.shared.properties.title = title
        CUAlertHUD.shared.properties.float = value
        CUAlertHUD.hudType = type
        if(CUAlert.anyAlertPresenting && CUAlertHUD.isHudPresenting){
            
            CUAlertHUD.shared.update()
        }
        else{
            
            CUAlertHUD.shared.present()
        }
        guard duration > 0 else { return }
        Self.dismiss(delay: duration)
    }
    
    public static func dismiss(delay:TimeInterval = 0,completionHandler:(()->Void)? = nil){
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            CUAlertHUD.shared.hide(completion: completionHandler)
        }
    }

    override func layout(containerView: CUAlertContainer) {
        //
        
        self.backgroundColor = config.backgroundColor
        self.layer.cornerRadius = config.cornerRadius
        var targetBaseView:CUAlertHUDBaseView!
        switch Self.hudType{
        case .loading:
            targetBaseView = CUAlertHUDProgressView()
            break
        case .progress:
            targetBaseView = CUAlertHUDProgressView()
            break
        case .error:
            targetBaseView = CUAlertHUDStatusView()
            break
        case .success:
            targetBaseView = CUAlertHUDStatusView()
            break
        }
        properties.value = Self.hudType
        targetBaseView.update(limitRect,properties: properties)
        targetBaseView.layout(limitRect)
        
        self.hudView = targetBaseView
        hudView!.frame = hudView!.bounds
        self.addSubview(hudView!)
    }
    
    override func present(containerView: CUAlertContainer) {
        self._hudType = Self.hudType
        let inner = self.hudView!.bounds.size
        let newFrame = CGRect(x: (SCREEN_WIDTH-inner.width)/2, y: (SCREEN_HEIGHT-inner.height)/2, width: inner.width, height: inner.height)
        self.frame = newFrame
        self.alpha = 0
        containerView.backdropView.alpha = 0
        Self._isHudPresenting = true
        UIView.animate(withDuration: config.animDuration) {
            [weak self] in
            self?.alpha = 1
            containerView.backdropView.alpha = 0.4
        }
    }
    
    
    override func hide(containerView: CUAlertContainer, completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: config.animDuration) {
            [weak self] in
            self?.alpha = 0
            containerView.backdropView.alpha = 0
        } completion: { [weak self] (_) in
            self?.hudView?.dismiss()
            self?.hudView?.removeFromSuperview()
            self?.hudView = nil
            self?._hudType = nil
            Self._isHudPresenting = false
            completion()
        }

    }
    
    override func update(actions: [CUAlertAction], properties: inout CUAlert.Property) {
        
        
        
        if Self.hudType != self._hudType {
            
            var targetBaseView:CUAlertHUDBaseView!
            switch Self.hudType{
            case .loading:
                targetBaseView = CUAlertHUDProgressView()
                break
            case .progress:
                targetBaseView = CUAlertHUDProgressView()
                break
            case .error:
                targetBaseView = CUAlertHUDStatusView()
                break
            case .success:
                targetBaseView = CUAlertHUDStatusView()
                break
            }
            properties.value = Self.hudType
            targetBaseView.update(limitRect,properties: properties)
            targetBaseView.layout(limitRect)
            targetBaseView.alpha = 0
            
            UIView.animate(withDuration: 0.4) {
                [weak self] in
                self?.hudView?.alpha = 0
            } completion: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.hudView?.dismiss()
                strongSelf.hudView?.removeFromSuperview()
                strongSelf.hudView?.snp.removeConstraints()
                strongSelf.hudView? = targetBaseView
                strongSelf.addSubview(strongSelf.hudView!)
                strongSelf.hudView!.frame = strongSelf.hudView!.bounds
                let inner = targetBaseView.bounds.size
                let newFrame = CGRect(x: (SCREEN_WIDTH-inner.width)/2, y: (SCREEN_HEIGHT-inner.height)/2, width: inner.width, height: inner.height)
                
                UIView.animate(withDuration: strongSelf.config.animDuration, delay: 0, options: .curveEaseOut, animations: {
                    [weak self] in
                    self?.frame = newFrame
                }, completion: {
                    [weak self] _ in
                    UIView.animate(withDuration: strongSelf.config.animDuration) {
                        strongSelf.hudView?.alpha = 1
                    }
                    self?._hudType = Self.hudType
                })

            }

        }
        else{
            properties.value = Self.hudType
            hudView!.update(limitRect,properties: properties)
            hudView!.layout(limitRect)
            let inner = hudView!.bounds.size
            let newFrame = CGRect(x: (SCREEN_WIDTH-inner.width)/2, y: (SCREEN_HEIGHT-inner.height)/2, width: inner.width, height: inner.height)
            UIView.animate(withDuration: config.animDuration, delay: 0, options: .curveEaseOut, animations: {
                [weak self] in
                guard let strongSelf = self else { return }
                self?.frame = newFrame
                self?.hudView?.frame = strongSelf.hudView!.bounds
                self?.layoutSubviews()
            }, completion: nil)

        }
        
    }
    
}

extension CUAlertHUD:CUAlertCustomPresentSource{
    
    func customPresentView() -> CUAlertBaseView {
        return self
    }
    
}


//MARK: HUD Base View
fileprivate class CUAlertHUDBaseView:UIView{
    //布局
    func layout(_ rect:CGRect){}
    //更新
    func update(_ rect:CGRect,properties:CUAlert.Property){ }
    //隐藏
    func dismiss(){}
    
}


//MARK: HUD Status View
fileprivate class CUAlertHUDStatusView:CUAlertHUDBaseView{
    
    private struct Config{
        var statusSize = CGSize(width: 40, height: 40)
        var statusTopMargin:CGFloat = 15
        var statusBottomMargin:CGFloat = 15
        var textBottomMargin:CGFloat = 15
        var textSideMargin:CGFloat = 15
        var minSize = CGSize(width: 60, height: 60)
        var frameEdgeMargin:CGFloat = 15
    }
    
    private lazy var statusView:UIImageView = UIImageView()
    private lazy var statusLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    private let config:Config = Config()
    
    override func layout(_ rect:CGRect) {
        statusLabel.removeFromSuperview()
        statusLabel.removeFromSuperview()
        if statusLabel.text == "" || statusLabel.text == nil{
            self.addSubview(statusView)
            statusView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(config.statusSize)
            }
        }
        else{
            self.addSubview(statusView)
            statusView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(config.statusTopMargin)
                make.size.equalTo(config.statusSize)
            }
            self.addSubview(statusLabel)
            statusLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(config.textSideMargin)
                make.right.equalTo(-config.textSideMargin)
                make.top.equalTo(statusView.snp.bottom).offset(config.statusBottomMargin)
                make.bottom.equalTo(-config.textBottomMargin)
            }
            
        }
    }
    
    override func update(_ rect:CGRect,properties: CUAlert.Property) {
        guard let status = properties.value as? CUAlertHUD.HUDType else { return }
        switch status{
        case .success:
            self.statusView.image = UIImage(named: "icon_check")
        case .error:
            self.statusView.image = UIImage(named: "icon_error")
        default:
            break
        }
        self.statusLabel.text = properties.title?.localize()
        
        if properties.title == "" || properties.title == nil{
            self.bounds.size = config.minSize
        }
        else{
            self.bounds.size = calcFrameSize(rect,properties: properties)
        }
    }
    
    func calcFrameSize(_ rect:CGRect,properties:CUAlert.Property) -> CGSize{
        let textHeight = String.getHeight(properties.title!, width: rect.width - config.textSideMargin*2, font: statusLabel.font)
        //小于一行
        if textHeight < 19{
            //计算宽度
            let textWidth = String.getWidth(properties.title!, height: rect.height, font: statusLabel.font)+2
            return CGSize(width: textWidth + config.textSideMargin*2, height: config.statusTopMargin+config.statusSize.height+config.statusBottomMargin+18+config.textBottomMargin)
        }
        else{
            return CGSize(width: rect.width - config.textSideMargin*2, height: config.statusTopMargin+config.statusSize.height+config.statusBottomMargin+textHeight+config.textBottomMargin)
        }
    }
}

//MARK: HUD Progress View
fileprivate class CUAlertHUDProgressView:CUAlertHUDBaseView{
    
    private struct Config{
        var progressSize = CGSize(width: 40, height: 40)
        var progressTopMargin:CGFloat = 15
        var progressBottomMargin:CGFloat = 15
        var textBottomMargin:CGFloat = 15
        var textSideMargin:CGFloat = 15
        var minSize = CGSize(width: 60, height: 60)
        var frameEdgeMargin:CGFloat = 15
    }
    
    
    private lazy var progressView = CUProgressView()
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    private let config = Config()
    
    
    override func layout(_ rect: CGRect) {
        self.titleLabel.removeFromSuperview()
        if !self.subviews.contains(progressView){
            self.addSubview(progressView)
        }
        if self.titleLabel.text == "" || self.titleLabel.text == nil{
            progressView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(config.progressSize)
            }
        }
        else{
            progressView.snp.remakeConstraints { (make) in
                make.top.equalTo(config.progressTopMargin)
                make.centerX.equalToSuperview()
                make.size.equalTo(config.progressSize)
            }
            self.addSubview(titleLabel)
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(progressView.snp.bottom).offset(config.progressBottomMargin)
                make.left.equalTo(config.textSideMargin)
                make.right.equalTo(-config.textSideMargin)
                make.bottom.equalTo(-config.textBottomMargin)
            }
        }
        
    }
    
    override func update(_ rect: CGRect, properties: CUAlert.Property) {
        guard let status = properties.value as? CUAlertHUD.HUDType else { return }

        switch status{
        case .progress:
            guard let value = properties.float,value <= 1 && value >= 0 else { return }
            self.progressView.setProgress(Int(value * 100), animated: true)
        case .loading:
            
            self.progressView.loopAnim(start: true)
            
        default:
            break
        }
        self.titleLabel.text = properties.title
        if properties.title == "" || properties.title == nil{
            self.bounds.size = config.minSize
        }
        else{
            self.bounds.size = calcFrameSize(rect,properties: properties)
        }
        
    }
    
    
    func calcFrameSize(_ rect:CGRect,properties:CUAlert.Property) -> CGSize{
        let textHeight = String.getHeight(properties.title!, width: rect.width - config.textSideMargin*2, font: titleLabel.font)
        //小于一行
        if textHeight < 19{
            //计算宽度
            let textWidth = String.getWidth(properties.title!, height: rect.height, font: titleLabel.font)+2
            return CGSize(width: max(textWidth,config.minSize.width) + config.textSideMargin*2, height: config.progressTopMargin+config.progressSize.height+config.progressBottomMargin+18+config.textBottomMargin)
        }
        else{
            return CGSize(width: rect.width - config.textSideMargin*2, height: config.progressTopMargin+config.progressSize.height+config.progressBottomMargin+textHeight+config.textBottomMargin)
        }
    }
    
    override func dismiss() {
        self.progressView.loopAnim(start: false)
    }
    
}


