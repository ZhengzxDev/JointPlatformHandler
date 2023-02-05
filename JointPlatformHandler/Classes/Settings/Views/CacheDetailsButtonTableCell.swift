//
//  CacheDetailsButtonTableCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/17.
//

import UIKit

protocol cacheDetailButtonDelegate:NSObjectProtocol{
    
    func cacheButtonCell(_ tableCell:CacheDetailsButtonTableCell,didPressButtonWith property:[String:Any])
    
}

class CacheDetailsButtonTableCell: UITableViewCell {
    
    public weak var delegate:cacheDetailButtonDelegate?
    
    @IBOutlet weak var oprationButton: UIButton!
    
    private var propertyDic:[String:String] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.oprationButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(model: Any?) {
        guard let propertyDic = model as? [String:String] else { return }
        self.propertyDic = propertyDic
        self.oprationButton.setTitle(propertyDic["title"], for: .normal)
    }
    
    @IBAction func onPressButton(_ sender: Any) {
        delegate?.cacheButtonCell(self, didPressButtonWith: self.propertyDic)
    }
}
