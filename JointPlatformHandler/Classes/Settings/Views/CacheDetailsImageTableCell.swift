//
//  CacheDetailsImageTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/16.
//

import UIKit

class CacheDetailsImageTableCell: UITableViewCell {

    @IBOutlet weak var containerView: ZxCornerView!
    @IBOutlet weak var gameIconView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        containerView.corners = [.topLeft,.topRight]
        containerView.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(model: Any?) {
        guard let cachedGame = model as? GameAssetsManager.CachedGameAssetsEntity else { return }
        if cachedGame.iconData != nil{
            self.gameIconView.image = UIImage(data: cachedGame.iconData!)
        }
        else{
            self.gameIconView.image = UIImage(named: "icon_game_holder")
        }
        self.gameNameLabel.text = cachedGame.profile.name
        self.gameIdLabel.text = "  GID \(cachedGame.profile.id ?? "null")  "
    }
    
}
