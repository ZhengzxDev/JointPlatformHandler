//
//  AvatarSelectCollectionCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit

class AvatarSelectCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        imageView.backgroundColor = UIColor.clear
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = StyleConfig.Colors.background.cgColor
    }
    
    override func setup(model: Any?) {
        guard let imageName  = model as? String else { return }
        self.imageView.image = UIImage(named: imageName)
    }

}
