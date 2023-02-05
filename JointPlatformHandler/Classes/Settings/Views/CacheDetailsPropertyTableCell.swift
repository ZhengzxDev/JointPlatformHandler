//
//  CacheDetailsPropertyTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/16.
//

import UIKit

class CacheDetailsPropertyTableCell: UITableViewCell {

    @IBOutlet weak var containerView: ZxCornerView!
    @IBOutlet weak var propertyNameLabel: UILabel!
    @IBOutlet weak var propertyValueLabel: UILabel!
    
    
    private var isLastCell:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.containerView.corners = [.bottomLeft,.bottomRight]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isLastCell = false
        self.containerView.cornerRadius = 0
    }
    
    func setLastCell(_ value:Bool){
        self.isLastCell = value
        if value{
            self.containerView.cornerRadius = 8
        }
        else{
            self.containerView.cornerRadius = 0
        }
    }
    
    override func setup(model: Any?) {
        guard let propertyDic = model as? [String:String] else { return }
        self.propertyValueLabel.text = propertyDic["value"]
        self.propertyNameLabel.text = propertyDic["title"]
        
    }
}
