//
//  LobbyHeaderView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/5.
//

import UIKit

class LobbyHeaderView:UIView,NibLoadable{
    
    private var contentView:UIView?
    @IBOutlet weak var titleLabel: UILabel!
    
    private var loadIndicator:CULoadingIndicator = CULoadingIndicator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadFromNib()
        self.addSubview(contentView!)
        self.backgroundColor = UIColor.clear
        self.contentView?.backgroundColor = UIColor.clear
        contentView!.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loadIndicator.setSize(CGSize(width: 25, height: 25))
        self.contentView?.addSubview(loadIndicator)
        loadIndicator.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        titleLabel.textColor = StyleConfig.Colors.heavyTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setLoading(_ value:Bool){
        if value{
            self.loadIndicator.isHidden = false
            self.loadIndicator.play()
        }
        else{
            self.loadIndicator.isHidden = true
            self.loadIndicator.pause()
        }
    }
    
}
