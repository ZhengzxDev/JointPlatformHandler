//
//  RoomViewController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit

class RoomViewController: UIViewController {
    
    private let playerCellId:String = "playerCell"
    private let emptySeatCellId:String = "emptySeatCell"
    private let roomInfoCellId:String = "roomInfoCell"
    
    private let roomInfoConfig:[[String:String]] = [
        [
            "icon":"lobby_server",
            "type":"host"
        ],
        [
            "icon":"room_game",
            "type":"game"
        ],
        [
            "icon":"room_signal",
            "type":"signal"
        ],
    ]
    
    public var roomModel:GameRoom!
    
    weak var lobbyController:LobbyViewController!
    
    private var isSelfReady:Bool = false
    
    private var signalCellIndex:IndexPath?
    
    private var delayOnDisplay:Double = 1000
    
    private var joyStickController:JoyStickController?
    
    private var isInGame:Bool = false
    
    // 当前statusBar使用的样式
    var statuBarStyle: UIStatusBarStyle = .darkContent
    
    private lazy var navigationBar:JtNavigationBar = {
        let bar = JtNavigationBar()
        bar.setDelegate(self)
        let item = UINavigationItem()
        bar.items = [item]
        return bar
    }()
    
    private lazy var tableView:UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(UINib(nibName: "RoomPlayerTableCell", bundle: .main), forCellReuseIdentifier: playerCellId)
        view.register(UINib(nibName: "RoomEmptySeatTableCell", bundle: .main), forCellReuseIdentifier: emptySeatCellId)
        view.register(UINib(nibName: "RoomInfoTableCell", bundle: .main), forCellReuseIdentifier: roomInfoCellId)
        view.separatorStyle = .none
        view.backgroundColor = UIColor.clear
        view.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    private lazy var readyButton:CUButton = {
        let view = CUButton()
        view.imageSize = CGSize(width: 30, height: 30)
        view.setImage(UIImage(named: "room_ready"), for: .normal)
        view.imageView?.tintColor = StyleConfig.Colors.theme
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 30
        view.addTarget(self, action: #selector(onPressReadyButton), for: .touchUpInside)
        return view
    }()
    
        // 重现statusBar相关方法
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return self.statuBarStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isInGame = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("[RoomViewController] init")
        self.view.backgroundColor = StyleConfig.Colors.background
        self.view.addSubview(navigationBar)
        self.navigationBar.title = self.title ?? ""
        self.tableView.backgroundColor = UIColor.clear
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(statusBarHeight + 50)
            make.left.right.bottom.equalToSuperview()
        }
        self.view.addSubview(readyButton)
        readyButton.snp.makeConstraints { make in
            make.bottom.equalTo(-BOTTOM_INSET-20)
            make.right.equalTo(-20)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        self.view.bringSubviewToFront(navigationBar)
        setNeedsStatusBarAppearanceUpdate()
        refreshRoomPlayerDisplay()
        refreshReadyButtonDisplay(isSelfReady)
        NotificationCenter.customAddObserver(self, selector: #selector(onDelayPacketUpdate(_:)), name: .DelayPacketUpdate, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerEnter(_:)), name: .PlayerEnter, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerLeave(_:)), name: .PlayerLeave, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerReady(_:)), name: .PlayerReady, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerNotReady(_:)), name: .PlayerNotReady, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGamePrepare(_:)), name: .GamePrepare, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGamePrepareFailed(_:)), name: .GamePrepareFailed, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGameAssetsPrepareDone(_:)), name: .GameAssetsPrepareDone, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onRoomDestory(_:)), name: .DidLeaveRoom, object: nil)
    }
    
    deinit{
        debugLog("[RoomViewController] deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshRoomPlayerDisplay(){
        navigationBar.title = "\(roomModel.playerCount)/\(roomModel.capacity)"
    }
    
    func refreshReadyButtonDisplay(_ isReady:Bool){
        if isReady{
            readyButton.imageView?.tintColor = UIColor.white
            readyButton.backgroundColor = StyleConfig.Colors.theme
        }
        else{
            readyButton.imageView?.tintColor = StyleConfig.Colors.theme
            readyButton.backgroundColor = UIColor.white
        }
    }
    
    @objc func onPressReadyButton(){
        isSelfReady = !isSelfReady
        guard Client.instance.roomManager?.setReady(isSelfReady) ?? false else {
            debugLog("[RoomViewController] sync ready failed")
            return
        }
        refreshReadyButtonDisplay(isSelfReady)
        for (idx,player) in roomModel.players.enumerated(){
            if player.user.uid == GameUser.this.uid{
                roomModel.players[idx].isReady = isSelfReady
                self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
            }
        }
    }
    


}


extension RoomViewController{
    
    
    @objc private func onDelayPacketUpdate(_ notification:Notification){
        guard let delay = notification.userInfo?[JtUserInfo.Key.Value] as? Double else { return }
        guard self.navigationController?.topViewController == self else { return }
        self.delayOnDisplay = delay
        guard self.signalCellIndex != nil else { return }
        self.tableView.reloadRows(at: [signalCellIndex!], with: .none)
    }
    
    @objc
    private func onPlayerEnter(_ notification:Notification){
        guard let player = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        roomModel.playerCount+=1
        roomModel.players.append(player)
        self.tableView.reloadData()
        refreshRoomPlayerDisplay()
    }
    
    @objc
    private func onPlayerLeave(_ notification:Notification){
        guard let exitPlayer = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        roomModel.playerCount-=1
        for (idx,player) in roomModel.players.enumerated(){
            if player.user.uid == exitPlayer.user.uid{
                roomModel.players.remove(at: idx)
            }
        }
        self.tableView.reloadData()
        refreshRoomPlayerDisplay()
    }
    
    @objc
    private func onPlayerReady(_ notification:Notification){
        guard let readyPlayerId = notification.userInfo?[JtUserInfo.Key.Value] as? String else { return }
        for (idx,player) in roomModel.players.enumerated(){
            if player.playerId == readyPlayerId{
                roomModel.players[idx].isReady = true
                self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
            }
        }
    }
    
    @objc
    private func onPlayerNotReady(_ notification:Notification){
        guard let notReadyPlayerId = notification.userInfo?[JtUserInfo.Key.Value] as? String else { return }
        for (idx,player) in roomModel.players.enumerated(){
            if player.playerId == notReadyPlayerId{
                roomModel.players[idx].isReady = false
                self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
            }
        }
    }
    
    @objc
    private func onGamePrepare(_ notification:Notification){
        CUAlertHUD.display(title: "正在准备资源..", type: .loading)
    }
    
    @objc
    private func onGamePrepareFailed(_ notification:Notification){
        guard !isInGame else { return }
        guard let error = notification.userInfo?[JtUserInfo.Key.Error] as? NSError else {
            CUAlertHUD.display(title: "加载由于未知错误终止", type: .error,duration: 1.5)
            return
        }
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
    
    @objc
    private func onGameAssetsPrepareDone(_ notification:Notification){
        guard let stickConfig = notification.userInfo?[JtUserInfo.Key.Value] as? [String:Any] else { return }
        let assets = GameAssetsManager.shared.getAssets(for: roomModel.game)
        joyStickController = JoyStickController()
        joyStickController?.initialize(game: roomModel.game, stickConfig: stickConfig, assets: assets)
        self.isInGame = true
        self.navigationController?.pushViewController(joyStickController!, animated: true)
        CUAlertHUD.dismiss()
    }
    
    
    @objc
    private func onRoomDestory(_ notification:Notification){
        guard !isInGame else { return }
        CUAlertHUD.dismiss()
        let alert = CUAlert(type: .Alert)
        alert.properties.content = "主机已经关闭房间"
        alert.properties.title = "提示"
        alert.addAction(name: "确认") { [weak self] alert in
            self?.navigationController?.popViewController(animated: true)
            alert.hide()
        }
        alert.present()
    }
    

}

extension RoomViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < roomModel.capacity {
            return 65
        }
        else{
            return 30
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let playerCount = roomModel.capacity
        return playerCount + self.roomInfoConfig.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if indexPath.row < roomModel.capacity {
            if indexPath.row < roomModel.playerCount{
                cell = tableView.dequeueReusableCell(withIdentifier: playerCellId)
                cell?.setup(model: roomModel.players[indexPath.row])
            }
            else{
                //空位cell
                cell = tableView.dequeueReusableCell(withIdentifier: emptySeatCellId)
            }
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: roomInfoCellId)
            var config = self.roomInfoConfig[indexPath.row - roomModel.capacity]
            switch config["type"]{
            case "host":
                config["content"] = roomModel.hoster.ip_v4_address ?? "0.0.0.0"
                cell.setup(model: config)
            case "game":
                config["content"] = roomModel.game.name
                cell.setup(model: config)
            case "signal":
                var delay:Int = Int(delayOnDisplay)
                delay = delay > 999 ? 999 : delay
                config["content"] = "\(delay)ms"
                cell.setup(model: config)
                signalCellIndex = indexPath
            default:
                print("unmatched config type")
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
    
    
}



extension RoomViewController:JtNavigationViewDelegate{
    func jtNavigationViewOnPressBack() {
        NotificationCenter.default.removeObserver(self)
        Client.instance.roomManager?.exitCurrentRoom()
        self.navigationController?.popViewController(animated: true)
    }
}
