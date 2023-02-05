//
//  AppInfoController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/15.
//

import UIKit

class AppInfoController: UIViewController {
    
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
        view.register(UINib(nibName: "AppInfoDetailsTableCell", bundle: .main), forCellReuseIdentifier: "detailCell")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于"
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
    

    

}

extension AppInfoController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_HEIGHT - statusBarHeight - 44
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension AppInfoController:JtNavigationViewDelegate{
    func jtNavigationViewOnPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

