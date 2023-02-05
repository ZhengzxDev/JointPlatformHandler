//
//  CacheManageTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/16.
//

import UIKit

class CacheManageTableCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gameIconView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameRightArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = StyleConfig.Colors.container
        self.backgroundColor = UIColor.clear
        self.gameIconView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(model: Any?) {
        guard let cachedGame = model as? GameAssetsManager.CachedGameAssetsEntity else { return }
        self.gameNameLabel.text = cachedGame.profile.name
        if cachedGame.iconData != nil{
            self.gameIconView.image = UIImage(data: cachedGame.iconData!)
        }
    }
    
}
