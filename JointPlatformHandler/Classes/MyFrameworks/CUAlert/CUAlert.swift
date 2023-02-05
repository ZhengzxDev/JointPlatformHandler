//
//  CUAlert.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2021/1/31.
//  Copyright © 2021 郑正雄. All rights reserved.
//

import UIKit

protocol CUAlertCustomPresentSource:NSObjectProtocol{
    func customPresentView() -> CUAlertBaseView
}

@objc
protocol CUAlertDelegate:NSObjectProtocol{
    @objc optional func cuAlert(didLayout alert:CUAlert)
    @objc optional func cuAlert(willPresent alert:CUAlert) -> Bool
    @objc optional func cuAlert(didPresent alert:CUAlert)
    @objc optional func cuAlert(willHide alert:CUAlert) -> Bool
    @objc optional func cuAlert(didHide alert:CUAlert)
}

class CUAlert:NSObject{
    
    //static var isPresenting:Bool = false
    
    
    static var anyAlertPresenting:Bool{
        get{
            return presentCount > 0
        }
    }
    static var presentCount:Int = 0
    
    struct Property{
        var value:Any?
        var float:CGFloat?
        var title:String?
        var content:String?
        var hideOnTouchMask:Bool = false
    }
    
    enum PresentMode{
        case Alert,ActionSheet,Custom
    }
    
    public var isPresenting:Bool = false
    public var properties:Property = Property()
    public var actions:[CUAlertAction] = []
    public var type:CUAlert.PresentMode = .Alert
    public var layoutBaseView:CUAlertBaseView?{
        get{
            return baseView
        }
    }
    public weak var presentSource:CUAlertCustomPresentSource?
    public weak var delegate:CUAlertDelegate?
    
    private var baseView:CUAlertBaseView?
    

    
    private lazy var container:CUAlertContainer = {
        let view = CUAlertContainer(ref: self)
        view.tapCallback = {
            [weak self] in
            guard self?.properties.hideOnTouchMask ?? false else { return }
            self?.hide()
        }
        return view
    }()
    private var sharedWindow:UIWindow?{
        get{
            return UIApplication.shared.keyWindow
        }
    }
    
    init(type:CUAlert.PresentMode = .Alert){
        //super.init(frame: CGRect.zero)
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func present(){
        guard isPresenting == false else { return }
        guard let window = self.sharedWindow else { return }
        
        switch self.type{
        case .Alert:
            baseView = CUAlertAlertView()
            break
        case .ActionSheet:
            baseView = CUAlertActionSheet()
            break
        case .Custom:
            
            guard let source = self.presentSource else { return }
            baseView = source.customPresentView()
            
        /*default:
            break*/
        }
        guard baseView != nil else { return }
        guard (delegate?.cuAlert?(willPresent: self) ?? true) == true else { return }
        container.initialize()
        container.addSubview(baseView!.view())
        layoutContent(base: baseView!)
        delegate?.cuAlert?(didLayout: self)
        window.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        baseView!.performer = self
        baseView!.present(containerView: container)
        delegate?.cuAlert?(didPresent: self)
        isPresenting = true
        CUAlert.presentCount += 1
    }
    
    public func update(){
        guard isPresenting else { return }
        self.baseView!.update(actions: self.actions, properties: &self.properties)
    }
    
    
    public func hide(completion:(()->Void)? = nil){
        guard (delegate?.cuAlert?(willHide: self) ?? true) == true else { return }
        baseView?.hide(containerView: container) {
            [weak self] in
            guard let strongSelf = self else {
                fatalError("[CUAlert] cant remove subviews from container")
            }
            strongSelf.container.dispose()
            strongSelf.baseView?.dispose()
            for view in strongSelf.container.subviews{
                view.removeFromSuperview()
            }
            strongSelf.container.removeFromSuperview()
            
            strongSelf.isPresenting = false
            CUAlert.presentCount -= 1
            self?.delegate?.cuAlert?(didHide: strongSelf)
            completion?()
        }
    }
    
    public func addAction(_ action:CUAlertAction){
        self.actions.append(action)
    }
    
    public func addAction(name:String,handler:((CUAlert)->Void)?,type:CUAlertAction.CUAlertActionType = .Default){
        let actionObj = CUAlertAction(name: name, action: handler)
        actionObj.actionType = type
        self.actions.append(actionObj)
    }
    
    private func layoutContent(base:CUAlertBaseProperty){
        base.initialize(actions: self.actions, properties: &self.properties)
        base.layout(containerView: self.container)
    }
}


extension CUAlert:CUAlertActionPerformer{
    
    func doAction(with action: CUAlertAction) {
        action.action?(self)
    }
    
    
}


class CUAlertAction:NSObject{
    
    public enum CUAlertActionType{
        case Default
        case Cancel
    }
    
    public var actionName:String = ""
    public var textAttribute:[NSAttributedString.Key:Any] = [:]
    public var action:((CUAlert)->Void)?
    public var actionType:CUAlertActionType = .Default
    public var tag:Int = 0
    
    init(name:String,action:((CUAlert)->Void)?){
        self.actionName = name
        self.action = action
    }
}
