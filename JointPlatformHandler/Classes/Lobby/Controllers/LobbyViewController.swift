//
//  LobbyViewController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit
import SnapKit

class LobbyViewController: UIViewController {
    
    
    private lazy var collectionView:UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
        view.delegate = self
        view.dataSource = self
        view.register(UINib(nibName: "LobbyListCollectionCell", bundle: .main), forCellWithReuseIdentifier: "itemCell")
        view.backgroundColor = StyleConfig.Colors.background
        return view
    }()
    
    private lazy var collectionViewLayout:LobbyListLayout = {
       let layout = LobbyListLayout()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: SCREEN_WIDTH - 50, height: 300)
        return layout
    }()
    
    private var headerView:LobbyHeaderView = LobbyHeaderView()
    
    private var holderView:HolderView = HolderView()
    
    private var roomList:[GameRoom] = []
    
    private var isInit:Bool = false
    
    private var headerHeight:CGFloat{
        get{
            return statusBarHeight + 60
        }
    }
    
        // 当前statusBar使用的样式
    var statuBarStyle: UIStatusBarStyle = .darkContent
    
         // 重现statusBar相关方法
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statuBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleConfig.Colors.background
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        
        self.view.addSubview(holderView)
        holderView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
        
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        NotificationCenter.customAddObserver(self, selector: #selector(onDidEnterRoom(_:)), name: .DidEnterRoom, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onDidEnterRoomFailed(_:)), name: .EnterRoomFailed, object: nil)
        
        holderView.display(title: "当前局域网没有房间", imageName: "lobby_empty")
        refreshDisplay()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        

        if !isInit {
            Client.instance.setConnectMode(.Lan)
            Client.instance.initComponents()
            Client.instance.roomManager?.finder?.setDelegate(self)
            
            isInit = true
        }
        
        guard Client.instance.roomManager?.finder?.startListening() ?? false else {
            CUAlertHUD.display(title: "开启监听失败", type: .error, duration: 2)
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Client.instance.roomManager?.finder?.stopListening()
        
        self.headerView.setLoading(false)
    }
    
    
    func refreshDisplay(){
        if roomList.count > 0{
            collectionView.isHidden = false
            holderView.isHidden = true
        }
        else{
            collectionView.isHidden = true
            holderView.isHidden = false
        }
    }

}

extension LobbyViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath)
        (cell as? LobbyListCollectionCell)?.setup(with: roomList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CUAlertHUD.display(title: "正在连接房间..", type: .loading)
        let roomModel = self.roomList[indexPath.row]
        guard Client.instance.roomManager?.enterRoom(roomModel) ?? false else {
            CUAlertHUD.display(title:"加入房间失败", type:.error,duration:2)
            return
        }
    }
    
}


extension LobbyViewController:GameRoomFinderDelegate{
    
    func gameRoomFinder(_ finder: GameRoomFinder, didFindWith list: [GameRoom]) {
        self.roomList = list
        headerView.setLoading(false)
        self.collectionView.reloadData()
        refreshDisplay()
    }
    
    func gameRoomFinderOnSearching() {
        headerView.setLoading(true)
    }
    
    func gameRoomFinderOnErrorTerminate(_ error: Error) {
        headerView.setLoading(false)
        let alert = CUAlert(type: .Alert)
        alert.properties.title = "提示"
        alert.properties.content = error.localizedDescription
        alert.addAction(name: "确定") { alert in
            alert.hide()
        }
    }
    
    
}

extension LobbyViewController{
    
    
    @objc
    private func onDidEnterRoom(_ notification:Notification){
        guard let roomModel = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoom else { return }
        CUAlertHUD.dismiss()
        let roomController = RoomViewController()
        roomController.roomModel = roomModel
        roomController.lobbyController = self
        roomController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(roomController, animated: true)
    }
    
    @objc
    private func onDidEnterRoomFailed(_ notification:Notification){
        CUAlertHUD.display(title:"加入房间超时", type:.error,duration:2)
    }
    
}

