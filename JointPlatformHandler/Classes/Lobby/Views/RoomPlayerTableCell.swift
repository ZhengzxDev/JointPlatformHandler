//
//  RoomPlayerTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

class RoomPlayerTableCell: UITableViewCell {

    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = StyleConfig.Colors.container
        self.nameLabel.textColor = StyleConfig.Colors.normalTitle
        self.stateImageView.tintColor = UIColor(hex: "#bebebe")
        
        self.clipsToBounds = false
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.035
        self.layer.shadowRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(model: Any?) {
        guard let player = model as? GameRoomPlayer else { return }
        self.avatarView.image = UIImage(named: userAvatarMap[player.user.avatarId ?? 0]!)
        self.nameLabel.text = player.user.nickName
        if player.isReady == true{
            self.stateImageView.image = UIImage(named: "room_ready")
        }
        else{
            self.stateImageView.image = nil
        }
    }
    
}
