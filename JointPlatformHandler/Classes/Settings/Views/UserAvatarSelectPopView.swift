//
//  UserAvatarSelectPopView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

class UserAvatarSelectPopView:CUAlertDragPopView{
    
    static let itemCellIdentifier:String = "avatarSelectPopCell"
    
    public lazy var collectionView:UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: selectLayout)
        view.backgroundColor = UIColor.clear
        view.register(UINib(nibName: "AvatarSelectCollectionCell", bundle: .main), forCellWithReuseIdentifier: UserAvatarSelectPopView.itemCellIdentifier)
        return view
    }()
    
    private lazy var selectLayout:H2RFlowLayout = {
        let layout = H2RFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.minimumInteritemSpacing = 20
        return layout
    }()
    
    
    override func getContentHeight() -> CGFloat {
        return 250
    }
    
    override func layoutPopViewContent() {
        self.contentContainer!.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
