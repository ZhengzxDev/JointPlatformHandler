//
//  JoyStickLayoutView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/23.
//

import UIKit

class JoyStickLayoutView:UIView{
    
    weak var controller:JoyStickController?
    
    var components:[JoyStickComponent] = []
    
    var needCustomLayout:Bool = false
    
    private var containers:[JoyStickLayoutContainerView] = []
    
    private var startPosition:[Int:CGPoint] = [:]
    
    private var startOffset:[Int:CGPoint] = [:]
    
    private var isEditingView:Bool = false
    
    private var layoutItems:[JoyStickLayoutItem] = []
    
    private var game:GameProfile?
    
    private var layoutVersion:String = ""
    
    private var lastSelectContainer:JoyStickLayoutContainerView?
    
    private var sizeAlert:CUAlert?
    
    private var isLayoutModified:Bool = false
    
    private lazy var sizeView:JoyStickComponentSizePopView = {
        let view = JoyStickComponentSizePopView()
        view.delegate = self
        return view
    }()
    
    convenience init(stickConfig:[String:Any],game:GameProfile,controller:JoyStickController){
        self.init(frame: CGRect.zero)
        
        self.controller = controller
        self.game = game

        layoutVersion = stickConfig["layoutVersion"] as? String ?? ""
        
        switch stickConfig["orient"] as? String ?? ""{
        case "landScape":
            controller.setOrientation(.Landscape)
        default:
            controller.setOrientation(.Portrait)
        }
        
        var savedVersion:String = ""
        var items:[JoyStickLayoutItem] = []
        
        if LayoutCacheManager.shared.hasLayout(for: game, version: &savedVersion){
            if savedVersion == layoutVersion{
                debugLog("[JoyStickLayoutView] layout load from cache")
                items = LayoutCacheManager.shared.getLayout(for: game)
                needCustomLayout = false
            }
            else{
                debugLog("[JoyStickLayoutView] layout updated")
                items = LayoutCacheManager.shared.convertAndUpdate(with: stickConfig, game: game)
                needCustomLayout = true
            }
        }
        else{
            debugLog("[JoyStickLayoutView] init layout")
            items = LayoutCacheManager.shared.convertAndSave(with: stickConfig ,game: game)
            needCustomLayout = true
        }
        
        layoutInterface(with: items)

        
    }
    
    
    private func layoutInterface(with items:[JoyStickLayoutItem]){
        self.layoutItems = items
        for item in items{
            item.component.initialize(self)
            let container = JoyStickLayoutContainerView(layoutItem: item)
            self.addSubview(container)
            self.containers.append(container)
            self.components.append(item.component)
        }
    }
    
    
    func toggleLayoutMode(_ value:Bool){
        if value{
            isLayoutModified = false
            for container in containers {
                container.component?.setEnable(false)
                let panRec = UIPanGestureRecognizer(target: self, action: #selector(onPanInContainer(_:)))
                container.addGestureRecognizer(panRec)
                let tapRec = UITapGestureRecognizer(target: self, action: #selector(onTapInContainer(_:)))
                container.addGestureRecognizer(tapRec)
                container.toggleEditMode(true)
                container.setSelected(false)
            }
        }
        else{
            
            lastSelectContainer = nil
            for container in containers {
                //update config
                for (idx,item) in self.layoutItems.enumerated(){
                    if item.component.comTag == container.component?.comTag{
                        let frame = container.getComponentViewRect()
                        self.layoutItems[idx].origin = frame.origin
                        self.layoutItems[idx].size = frame.size
                    }
                }
                container.toggleEditMode(false)
                container.component?.setEnable(true)
                if container.gestureRecognizers != nil{
                    for rec in container.gestureRecognizers!{
                        rec.removeTarget(self, action: #selector(onPanInContainer(_:)))
                        rec.removeTarget(self, action: #selector(onTapInContainer(_:)))
                        container.removeGestureRecognizer(rec)
                    }
                }
            }
            guard isLayoutModified else { return }
            LayoutCacheManager.shared.saveLayout(for: game!, items: self.layoutItems, version: layoutVersion)
        }
        self.isEditingView = value
    }
    
    @objc private func onPanInContainer(_ rec:UIPanGestureRecognizer){
        guard let container = rec.view as? JoyStickLayoutContainerView else { return }
        guard let component = container.component else { return }
        
        lastSelectContainer?.setSelected(false)
        container.setSelected(true)
        if rec.state == .began{
            self.bringSubviewToFront(container)
            let location = rec.location(in: self)
            startOffset[component.comTag] = CGPoint(x: location.x - container.frame.origin.x, y: location.y - container.frame.origin.y)
            startPosition[component.comTag] = CGPoint(x: container.frame.origin.x, y: container.frame.origin.y)
        }
        else if rec.state == .changed{
            let location = rec.location(in: self)
            let offsetX = location.x-startPosition[component.comTag]!.x-startOffset[component.comTag]!.x
            let offsetY = location.y-startPosition[component.comTag]!.y-startOffset[component.comTag]!.y
            container.frame.origin = CGPoint(x: startPosition[component.comTag]!.x+offsetX, y: startPosition[component.comTag]!.y+offsetY)
        }
        lastSelectContainer = container
        isLayoutModified = true
    }
    
    @objc private func onTapInContainer(_ rec:UITapGestureRecognizer){
        guard let container = rec.view as? JoyStickLayoutContainerView else { return }
        lastSelectContainer?.setSelected(false)
        container.setSelected(true)
        self.bringSubviewToFront(container)
        lastSelectContainer = container
        
        sizeAlert = CUAlert(type: .Custom)
        sizeAlert?.presentSource = self
        sizeAlert?.delegate = self
        sizeAlert?.present()
    }
    
    
}

extension JoyStickLayoutView:CUAlertCustomPresentSource{
    
    func customPresentView() -> CUAlertBaseView {
        return sizeView
    }
    
}

extension JoyStickLayoutView:JoyStickComponentSizePopViewDelegate{
    
    func componentSizePopView(_ view: JoyStickComponentSizePopView, didDragBarWith progress: CGFloat) {
        let baseSize = lastSelectContainer!.component!.defaultSize
        let multiper = (lastSelectContainer!.component!.maxSizeMultiper - 1) * progress
        let newSize = baseSize * (1+multiper)
        
        for i in 0 ..< self.layoutItems.count{
            if layoutItems[i].component.comTag == lastSelectContainer!.component!.comTag{
                layoutItems[i].size = newSize
            }
        }
        
        lastSelectContainer?.resizeComponentView(newSize)
        isLayoutModified = true
    }
    
    
}

extension JoyStickLayoutView:CUAlertDelegate{
    func cuAlert(willPresent alert: CUAlert) -> Bool {
        let baseValue = lastSelectContainer!.component!.defaultSize.height
        let currentValue = lastSelectContainer!.getComponentViewRect().height
        let maxValue = lastSelectContainer!.component!.defaultSize.height * lastSelectContainer!.component!.maxSizeMultiper
        self.sizeView.setDefaultProgress((currentValue - baseValue) / (maxValue - baseValue))
        return true
    }
}
