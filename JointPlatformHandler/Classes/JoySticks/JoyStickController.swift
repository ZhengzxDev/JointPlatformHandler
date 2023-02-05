//
//  JoyStickController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit
import SwiftyJSON

class JoyStickController: UIViewController {
    
    weak var lobbyController:LobbyViewController?
    
    private var layoutView:JoyStickLayoutView!
    
    private var assets:[String:Any] = [:]
    
    private let stateViewSize:CGSize = CGSize(width: 320, height: 30)
    
    private let stateViewTopMargin:CGFloat = 5
    
    private var orientation:GameJoyStick.Orientation = .Landscape
    
    private var isPrepareDone:Bool = false
    
    private var isEditingLayout:Bool = false
    
    private lazy var stateView:JoyStickConnectStateView = {
        let view = JoyStickConnectStateView()
        return view
    }()
    
    private var editLayoutButton:CUButton = {
        let button = CUButton()
        button.imageSize = CGSize(width: 15, height: 15)
        button.backgroundColor = UIColor.white
        button.setImage(UIImage(named: "stick_edit"), for: .normal)
        button.addTarget(self, action: #selector(onPressLayout), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var exitButton:CUButton = {
        let button = CUButton()
        button.imageSize = CGSize(width: 15, height: 15)
        button.backgroundColor = UIColor.white
        button.setImage(UIImage(named: "stick_exit"), for: .normal)
        button.addTarget(self, action: #selector(onPressExit), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard orientation == .Landscape else { return }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLandscape = false
        let value = UIInterfaceOrientation.unknown.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let orientationTarget = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("[JoyStickController] init")
        NotificationCenter.customAddObserver(self, selector: #selector(onDelayPacketUpdate(_:)), name: .DelayPacketUpdate, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onServerDisconnected(_:)), name: .DidLeaveRoom, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGamePrepareFailed(_:)), name: .GamePrepareFailed, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGameStart(_:)), name: .GameStart, object: nil)
        self.view.backgroundColor = UIColor.black
        setupUI()
        
    }
    
    deinit{
        debugLog("[JoyStickController] deinit")
        NotificationCenter.default.removeObserver(self)
        Client.instance.stickManager?.terminate()
    }
    
    
    func initialize(game:GameProfile,stickConfig:[String:Any],assets:[String:Any]){
        self.assets = assets
        self.layoutView = JoyStickLayoutView(stickConfig: stickConfig, game: game, controller: self)
    }
    
    func asset(for key:String) -> Any?{
        return assets[key]
    }
    
    func setOrientation(_ orient:GameJoyStick.Orientation){
        debugLog("[JoyStickController] orientation mode : \(orient)")
        self.orientation = orient
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleLandscape = orient == .Landscape
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    private func setupUI(){
        
        self.view.addSubview(stateView)
        stateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(stateViewSize)
            make.top.equalTo(stateViewTopMargin)
        }
        
        self.view.addSubview(layoutView)
        layoutView.snp.makeConstraints { make in
            make.top.equalTo(stateViewTopMargin + stateViewSize.height)
            make.left.bottom.right.equalToSuperview()
        }
        
        self.view.addSubview(editLayoutButton)
        editLayoutButton.snp.makeConstraints { make in
            make.left.equalTo(stateView.snp.right).offset(10)
            make.centerY.equalTo(stateView)
            make.size.equalTo(CGSize(width: 60, height: 20))
        }
        
        self.view.addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.right.equalTo(stateView.snp.left).offset(-10)
            make.centerY.equalTo(stateView)
            make.size.equalTo(CGSize(width: 60, height:     20))
        }
        
        self.view.bringSubviewToFront(stateView)

        if Client.instance.connectMode == .Lan{
            stateView.initialize(hosterAddress: Client.instance.roomManager?.currentRoom?.hoster.ip_v4_address ?? "unknown")
        }
        else{
            stateView.initialize(hosterAddress: "bluetooth")
        }
        
        for component in layoutView.components{
            component.setDelegate(self)
        }
        
        
        if layoutView.needCustomLayout {
            guard Client.instance.stickManager?.syncInitLayout() ?? false else {
                debugLog("[JoyStickController] sync init layout failed")
                return
            }
            debugLog("[JoyStickController] init layout")
            toggleLayoutEdit(true)
        }
        else{
            isPrepareDone = true
            guard Client.instance.stickManager?.syncPrepareDone() ?? false else {
                debugLog("[JoyStickController] sync prepare done failed")
                return
            }
            debugLog("[JoyStickController] sync prepare done")
        }
    }
    
    private func toggleLayoutEdit(_ value:Bool){
        if value{
            self.editLayoutButton.setImage(UIImage(named: "stick_save"), for: .normal)
        }
        else{
            self.editLayoutButton.setImage(UIImage(named: "stick_edit"), for: .normal)
        }
        self.layoutView.toggleLayoutMode(value)
        self.isEditingLayout = value
    }
    
    
    @objc private func onDelayPacketUpdate(_ notification:Notification){
        guard let delay = notification.userInfo?[JtUserInfo
                                                    .Key.Value] as? Double else { return }
        self.stateView.updateStatus(delay: delay)
    }
    

    
    @objc private func onServerDisconnected(_ notification:Notification){
        debugLog("[JoyStickController] lost connection to server")
        let alert = CUAlert(type: .Alert)
        alert.properties.title = "错误"
        alert.properties.content = "与服务器失去连接"
        alert.addAction(name: "确认") { [weak self] alert in
            alert.hide()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        alert.present()
    }
    
    @objc private func onGamePrepareFailed(_ notification:Notification){
        guard let error = notification.userInfo?[JtUserInfo.Key.Error] as? NSError else {
            CUAlertHUD.display(title: "加载由于未知错误终止", type: .error,duration: 1.5)
            return
        }
        self.navigationController?.popViewController(animated: true)
        switch error.code{
        case 1:
            CUAlertHUD.display(title: "加载发生错误(内部错误)", type: .error,duration: 1.5)
        case 2:
            CUAlertHUD.display(title: "加载发生错误(发送失败)", type: .error,duration: 1.5)
        case 3:
            CUAlertHUD.display(title: "加载发生错误(读取资源失败)", type: .error,duration: 1.5)
        case 4:
            CUAlertHUD.display(title: "加载发生错误(保存资源失败)", type: .error,duration: 1.5)
        case 5:
            CUAlertHUD.display(title: "服务器终止加载", type: .error,duration: 1.5)
        default:
            CUAlertHUD.display(title: "加载发生错误(无效错误码)", type: .error,duration: 1.5)
        }
    }
    
    @objc private func onGameStart(_ notification:Notification){
        Client.instance.roomManager?.launcher?.terminateProcedure()
        Client.instance.stickManager?.delegate = self
        Client.instance.stickManager?.run()
    }
    
    
    @objc private func onPressLayout(){
        if isEditingLayout{
            toggleLayoutEdit(false)
            if !isPrepareDone{
                isPrepareDone = true
                guard Client.instance.stickManager?.syncPrepareDone() ?? false else {
                    debugLog("[JoyStickController] sync prepare done failed")
                    return
                }
                debugLog("[JoyStickController] sync prepare done")
            }
        }
        else{
            toggleLayoutEdit(true)
        }
    }
    
    @objc private func onPressExit(){
        let alert = CUAlert(type: .Alert)
        alert.properties.title = "提示"
        alert.properties.content = "确定退出当前游戏房间吗?"
        alert.addAction(name: "确认") { [weak self] alert in
            guard let strongSelf = self else { return }
            NotificationCenter.default.removeObserver(strongSelf)
            alert.hide()
            Client.instance.roomManager?.exitCurrentRoom()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(name: "取消") { alert in
            alert.hide()
        }
        alert.present()
    }
    
}


extension JoyStickController:GameStickManagerDelegate{
    
    func stickManager(_ manager: GameStickManager, didReceiveCommand data: Data) {
        //受伤的震动
        let Json = JSON(data)
        let typeStr = Json["type"].stringValue
        if typeStr == GameSync.Symbol.gameTerminate.rawValue{
            Client.instance.stickManager?.terminate()
            let alert = CUAlert(type: .Alert)
            alert.properties.title = "提示"
            alert.properties.content = "游戏已被关闭"
            alert.addAction(name: "确认") { [weak self] alert in
                alert.hide()
                guard let strongSelf = self else { return }
                NotificationCenter.default.removeObserver(strongSelf)
                self?.navigationController?.popViewController(animated: true)
            }
            alert.present()
        }
    }
    
}

extension JoyStickController:GameJoyStickDelegate{
    
    func joyStick(onButtonPressd button: JoyStickButton) {
        guard Client.instance.stickManager?.instantSync(dictionary: [
            "action":[
                "tag":button.comTag!,
                "type":"press"
            ]
        ]) ?? false else {
            debugLog("[JoyStickController] sync action to server failed")
            return
        }
    }
    
    func joyStick(knob: JoyStickKnob, onMoved vector: CGVector, offsetDegree: CGFloat) {
        
        let divisor = pow(10.0,Double(2))
        let fixedX:Double = round(vector.dx*divisor)/divisor
        let fixedY:Double = round(vector.dy*divisor)/divisor
        let fixedOffset:Double = round(offsetDegree*divisor)/divisor
        
        guard Client.instance.stickManager?.regularSync(dictionary: [
            "action":[
                "tag":knob.comTag!,
                "type":"move",
                "vector":[
                    "x":fixedX,
                    "y":fixedY
                ],
                "offset":fixedOffset
            ]
        ]) ?? false else {
            debugLog("[JoyStickController] sync action to server failed")
            return
        }
        //print("knob:\(knob.configName) vector:[\(fixedX),\(fixedY)] degree:\(fixedOffset)")
    }
    
}
