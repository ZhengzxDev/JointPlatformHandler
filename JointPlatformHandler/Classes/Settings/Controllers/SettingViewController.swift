//
//  SettingViewController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/5.
//

import UIKit

class SettingViewController: UIViewController {
    
    private let cellConfig:[[String:String]] = [
        [
            "id":"headerCell",
            "title":"设置",
        ],
        [
            "id":"itemCell",
            "title":"个人信息",
            "icon":"setting_user_info",
        ],
        [
            "id":"itemCell",
            "title":"缓存管理",
            "icon":"setting_plugin",
        ],
        [
            "id":"itemCell",
            "title":"关于",
            "icon":"setting_about",
        ],
    ]
    
    private var headerHeight:CGFloat{
        get{
            return statusBarHeight + 60
        }
    }
    
    private let normalCellHeight:CGFloat = 60
    
    
    private lazy var tableView:UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(UINib(nibName: "SettingHeaderTableCell", bundle: .main), forCellReuseIdentifier: "headerCell")
        view.register(UINib(nibName: "SettingNormalTableCell", bundle: .main), forCellReuseIdentifier: "itemCell")
        view.separatorStyle = .none
        view.backgroundColor = UIColor.clear
        return view
    }()
    
        // 当前statusBar使用的样式
    var statuBarStyle: UIStatusBarStyle = .darkContent

         // 重现statusBar相关方法
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statuBarStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleConfig.Colors.background
        // Do any additional setup after loading the view.
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    

}


extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return headerHeight
        }
        return normalCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 0 ? "headerCell" : "itemCell")
        if indexPath.row == 0{
            (cell as? SettingHeaderTableCell)?.setup(with: cellConfig[0])
        }
        else{
            (cell as? SettingNormalTableCell)?.setup(with: cellConfig[indexPath.row])
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellConfig.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 1{
            let userInfoController = UserInfoViewController()
            userInfoController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(userInfoController, animated: true)
        }
        else if indexPath.row == 2{
            let cacheManageController = CacheManageController()
            cacheManageController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(cacheManageController, animated: true)
        }
        else if indexPath.row == 3{
            let appInfoController = AppInfoController()
            appInfoController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(appInfoController, animated: true)
        }
        
    }
    
    
    
}
