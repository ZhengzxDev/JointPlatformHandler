//
//  UserInfoAvatarCell.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit


protocol userInfoAvatarCellDelegate:NSObjectProtocol{
    func avatarCellOnPressImage()
    func avatarCellOnPressDone()
}

class UserInfoAvatarCell: UITableViewCell {

    @IBOutlet weak var nameInputField:UITextField!
    @IBOutlet weak var avatarView: UIImageView!
    
    private var tapRec:UITapGestureRecognizer?
    
    weak var delegate:userInfoAvatarCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameInputField.textColor = StyleConfig.Colors.normalTitle
        avatarView.backgroundColor = StyleConfig.Colors.container
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        tapRec = UITapGestureRecognizer(target: self, action: #selector(onPressAvatarImage))
        avatarView.addGestureRecognizer(tapRec!)
        avatarView.isUserInteractionEnabled = true
        
        nameInputField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with user:GameUser){
        
        self.nameInputField.text = user.nickName
        self.avatarView.image = UIImage(named: userAvatarMap[user.avatarId!]!)
        
    }
    
    @objc func onPressAvatarImage(){
        delegate?.avatarCellOnPressImage()
    }
    
}

extension UserInfoAvatarCell:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.avatarCellOnPressDone()
        return true
    }
    
}
