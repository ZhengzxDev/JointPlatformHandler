//
//  CacheDetailsController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/16.
//

import UIKit

class CacheDetailsController: UIViewController {
    
    private var listData:[[String:String]] = []
    
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
        view.register(UINib(nibName: "CacheDetailsImageTableCell", bundle: .main), forCellReuseIdentifier: "imageInfoCell")
        view.register(UINib(nibName: "CacheDetailsPropertyTableCell", bundle: .main), forCellReuseIdentifier: "propertyCell")
        view.register(UINib(nibName: "CacheDetailsButtonTableCell", bundle: .main), forCellReuseIdentifier: "buttonCell")
        view.separatorStyle = .none
        view.backgroundColor = UIColor.clear
        view.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        return view
    }()
    
    
    private var cachedGame:GameAssetsManager.CachedGameAssetsEntity?
    
    private var isAssetsDeleted:Bool = false
    private var isLayoutDeleted:Bool = false
    
    // 当前statusBar使用的样式
    var statuBarStyle: UIStatusBarStyle = .darkContent
    // 重现statusBar相关方法
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return self.statuBarStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "详细"
        self.view.backgroundColor = StyleConfig.Colors.background
        self.view.addSubview(navigationBar)
        self.navigationBar.title = self.title ?? ""
        self.tableView.backgroundColor = UIColor.clear
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        self.view.bringSubviewToFront(navigationBar)
        setNeedsStatusBarAppearanceUpdate()

    }
    
    public func setCachedGame(_ cachedGame:GameAssetsManager.CachedGameAssetsEntity){
        self.cachedGame = cachedGame
        calculateProperties()
    }
    
    private func calculateProperties(){
        guard self.cachedGame != nil else { return }
        let totalSize = GameAssetsManager.shared.getAssetsSize(for: cachedGame!.profile)
        let layoutSize = LayoutCacheManager.shared.getLayoutFileSize(for: cachedGame!.profile)
        let assetSize = totalSize - layoutSize
        isLayoutDeleted = layoutSize == 0
        isAssetsDeleted = assetSize == 0
        self.listData = [
            [
                "id":"imageInfoCell",
                "key":"imageInfo",
                "title":""
            ],
            [
                "id":"propertyCell",
                "title":"创建日期",
                "key":"modifyDate",
                "value":Date.getLocalDateStrWithDate(date: cachedGame!.createDate,format: "yyyy-MM-dd")
            ],
            [
                "id":"propertyCell",
                "title":"资源版本",
                "key":"assetsVersion",
                "value":cachedGame!.version == "" ? "unknown" : cachedGame!.version
            ],
            [
                "id":"propertyCell",
                "title":"资源文件数",
                "key":"assetsFileCount",
                "value":"\(cachedGame!.itemCount)"
            ],
            [
                "id":"propertyCell",
                "title":"资源大小",
                "key":"assetsCacheSize",
                "value":"\(Int(assetSize/1024))KB"
            ],
            [
                "id":"propertyCell",
                "title":"布局文件大小",
                "key":"layoutCacheSize",
                "value":"\(Int(layoutSize/1024))KB"
            ],
            [
                "id":"propertyCell",
                "title":"布局版本",
                "key":"layoutVersion",
                "value":"\(LayoutCacheManager.shared.getLayoutVersion(for: cachedGame!.profile) ?? "unknown")"
            ],
            [
                "id":"propertyCell",
                "title":"总大小",
                "key":"totalSize",
                "value":"\(Int(totalSize/1024))KB"
            ],
            [
                "id":"buttonCell",
                "title":"删除资源",
                "key":"deleteAssets",
            ],
            [
                "id":"buttonCell",
                "title":"删除布局缓存",
                "key":"deleteLayoutCache",
            ],
        ]
    }

}


extension CacheDetailsController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 90
        }
        else if indexPath.row == 8 || indexPath.row == 9{
            return 60
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let propertyDic = self.listData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: propertyDic["id"]!, for: indexPath)
        switch propertyDic["key"]{
        case "imageInfo":
            cell.setup(model: self.cachedGame)
        default:
            cell.setup(model: propertyDic)
            (cell as? CacheDetailsButtonTableCell)?.delegate = self
        }
        if indexPath.row == 7{
            (cell as? CacheDetailsPropertyTableCell)?.setLastCell(true)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
}


extension CacheDetailsController:cacheDetailButtonDelegate{
    
    func cacheButtonCell(_ tableCell: CacheDetailsButtonTableCell, didPressButtonWith property: [String : Any]) {
        guard property.keys.contains("key") else { return }
        guard let key = property["key"] as? String else { return }
        switch key {
        case "deleteAssets":
            guard !self.isAssetsDeleted else {
                CUAlertHUD.display(title: "资源已删除", type: .error, duration: 1.5)
                return
            }
            let alert = CUAlert(type: .Alert)
            alert.properties.content = "确定删除该游戏的所有资源？"
            alert.properties.title = "提示"
            alert.addAction(name: "确定") { [weak self] alert in
                guard let strongSelf = self else { return }
                alert.hide()
                guard GameAssetsManager.shared.deleteAssets(for: strongSelf.cachedGame!.profile) else {
                    CUAlertHUD.display(title: "删除失败",type: .error, duration: 1.5)
                    return
                }
                CUAlertHUD.display(title: "已删除",type: .success, duration: 1.5)
                self?.cachedGame?.itemCount = 0
                self?.cachedGame?.version = "unknown"
                self?.calculateProperties()
                
                if strongSelf.isAssetsDeleted && strongSelf.isLayoutDeleted{
                    let _ = GameAssetsManager.shared.deleteAssetsListRecord(for: strongSelf.cachedGame!.profile)
                    self?.navigationController?.popViewController(animated: true)
                }
                else{
                    self?.tableView.reloadData()
                }
                
            }
            alert.addAction(name: "取消") { alert in
                alert.hide()
            }
            alert.present()
        case "deleteLayoutCache":
            guard !self.isLayoutDeleted else {
                CUAlertHUD.display(title: "布局已删除", type: .error, duration: 1.5)
                return
            }
            let alert = CUAlert(type: .Alert)
            alert.properties.content = "确定删除该游戏的布局缓存？"
            alert.properties.title = "提示"
            alert.addAction(name: "确定") {[weak self] alert in
                guard let strongSelf = self else { return }
                alert.hide()
                guard LayoutCacheManager.shared.deleteLayout(for: strongSelf.cachedGame!.profile) else{
                    CUAlertHUD.display(title: "删除失败",type: .error, duration: 1.5)
                    return
                }
                CUAlertHUD.display(title: "已删除",type: .success, duration: 1.5)
                self?.calculateProperties()
                
                if strongSelf.isAssetsDeleted && strongSelf.isLayoutDeleted{
                    let _ = GameAssetsManager.shared.deleteAssetsListRecord(for: strongSelf.cachedGame!.profile)
                    self?.navigationController?.popViewController(animated: true)
                }
                else{
                    self?.tableView.reloadData()
                }
            }
            alert.addAction(name: "取消") { alert in
                alert.hide()
            }
            alert.present()
        default:
            break
        }
    }
    
    
}

extension CacheDetailsController:JtNavigationViewDelegate{
    func jtNavigationViewOnPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
