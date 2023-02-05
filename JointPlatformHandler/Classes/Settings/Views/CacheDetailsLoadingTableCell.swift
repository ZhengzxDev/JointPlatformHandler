//
//  CacheDetailsLoadingTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/16.
//

import UIKit

class CacheDetailsLoadingTableCell: UITableViewCell {
    
    private var loadIndicator:CULoadingIndicator = CULoadingIndicator()
    
    private var containerView:UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(containerView)
        containerView.layer.cornerRadius = 15
        containerView.backgroundColor = StyleConfig.Colors.container
        containerView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(15)
            make.top.bottom.equalToSuperview()
        }
        
        loadIndicator.setSize(CGSize(width: 25, height: 25))
        self.containerView.addSubview(loadIndicator)
        loadIndicator.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        loadIndicator.play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadIndicator.pause()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
