//
//  RoomInfoTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/7.
//

import UIKit

class RoomInfoTableCell: UITableViewCell {
    
    private let cellTintColor:UIColor = UIColor(r: 205, g: 205, b: 205, a: 1)

    @IBOutlet weak var infoIconView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        infoLabel.textColor = cellTintColor
        infoIconView.backgroundColor = UIColor.clear
        infoIconView.tintColor = cellTintColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(model: Any?) {
        guard let dic = model as? [String:String] else { return }
        self.infoLabel.text = dic["content"]
        guard let imageName = dic["icon"] else { return }
        self.infoIconView.image = UIImage(named: imageName)
    }
    
}
