//
//  LobbyListCollectionCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/5.
//

import UIKit

class LobbyListCollectionCell: UICollectionViewCell {

    @IBOutlet weak var hostIconView: UIImageView!
    @IBOutlet weak var playerIconView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var hostInfoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = StyleConfig.Colors.container
        self.gameNameLabel.textColor = StyleConfig.Colors.heavyTitle
        self.playerCountLabel.textColor = StyleConfig.Colors.footnotes
        self.hostInfoLabel.textColor = StyleConfig.Colors.footnotes
        self.gameNameLabel.lineBreakMode = .byCharWrapping
        self.playerIconView.tintColor = StyleConfig.Colors.theme
        self.playerIconView.tintColor = StyleConfig.Colors.theme
        
        self.clipsToBounds = false
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.035
        self.layer.shadowRadius = 3
    }
    
    func setup(with room:GameRoom){
        self.gameNameLabel.text = room.game.name
        self.playerCountLabel.text = "\(room.playerCount)/\(room.capacity)"
        self.hostInfoLabel.text = room.hoster.ip_v4_address
    }

}
