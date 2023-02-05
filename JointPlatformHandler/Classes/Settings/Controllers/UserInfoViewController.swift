//
//  UserInfoViewController.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

class UserInfoViewController: UIViewController {
    
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
        view.register(UINib(nibName: "UserInfoAvatarCell", bundle: .main), forCellReuseIdentifier: "avatarCell")
        view.separatorStyle = .none
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var avatarSelectPopView:UserAvatarSelectPopView = {
        let view = UserAvatarSelectPopView()
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        return view
    }()
    
        // 当前statusBar使用的样式
    var statuBarStyle: UIStatusBarStyle = .darkContent
    
    private var textInputField:UITextField?
    
    private var alertView:CUAlert?

         // 重现statusBar相关方法
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statuBarStyle
    }
        

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人信息"
        self.view.backgroundColor = StyleConfig.Colors.background
        self.view.addSubview(navigationBar)
        self.navigationBar.title = self.title ?? ""
        self.tableView.backgroundColor = UIColor.clear
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.bringSubviewToFront(navigationBar)
        setNeedsStatusBarAppearanceUpdate()
    }
    

}


extension UserInfoViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return SCREEN_HEIGHT/3 +  30
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "avatarCell")
        (cell as? UserInfoAvatarCell)?.setup(with: GameUser.this)
        (cell as? UserInfoAvatarCell)?.delegate = self
        textInputField = (cell as? UserInfoAvatarCell)?.nameInputField
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textInputField?.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textInputField?.resignFirstResponder()
    }
    
}


extension UserInfoViewController:userInfoAvatarCellDelegate{
    
    func avatarCellOnPressImage() {
        alertView = CUAlert(type: .Custom)
        alertView?.presentSource = self
        alertView?.present()
    }
    
    func avatarCellOnPressDone(){
        guard let textField = textInputField else { return }
        textField.resignFirstResponder()
        
        var inputStr = textField.text ?? ""
        inputStr = inputStr.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        
        if(inputStr == "" || inputStr.count > 15){
            let alert = CUAlert(type: .Alert)
            alert.properties.content = "内容不合法"
            alert.properties.title = "提示"
            alert.addAction(name: "确认") { alert in
                alert.hide()
            }
            alert.present()
            textField.text = GameUser.this.nickName
        }
        else{
            GameUser.this.nickName = inputStr
            textField.text = inputStr
        }
        
    }
    
}

extension UserInfoViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userAvatarMap.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserAvatarSelectPopView.itemCellIdentifier, for: indexPath)
        cell.setup(model: userAvatarMap[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        alertView?.hide()
        let newAvatarId = indexPath.row
        if newAvatarId != GameUser.this.avatarId{
            GameUser.this.avatarId = newAvatarId
            tableView.reloadData()
        }
    }
    
    
}


extension UserInfoViewController:JtNavigationViewDelegate{
    func jtNavigationViewOnPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension UserInfoViewController:CUAlertCustomPresentSource{
    
    func customPresentView() -> CUAlertBaseView {
        return self.avatarSelectPopView
    }
    
    
}
