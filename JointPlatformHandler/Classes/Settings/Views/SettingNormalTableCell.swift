//
//  SettingNormalTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

class SettingNormalTableCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        containerView.backgroundColor = StyleConfig.Colors.container
        titleLabel.textColor = StyleConfig.Colors.heavyTitle
        iconImageView.tintColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with config:[String:String]){
        self.titleLabel.text = config["title"]
        self.iconImageView.image = UIImage(named: config["icon"] ?? "")
    }
    
}
