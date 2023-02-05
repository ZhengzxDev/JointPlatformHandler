//
//  JoyStickConnectStateView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/11.
//

import UIKit

class JoyStickConnectStateView: UIView,NibLoadable {
    
    private var contentView:UIView?
    
    @IBOutlet weak var delayIconView: UIImageView!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var hosterLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadFromNib()
        self.addSubview(contentView!)
        self.backgroundColor = UIColor.clear
        self.contentView!.backgroundColor = UIColor(r: 30, g: 30, b: 30, a: 0.8)
        self.contentView!.layer.cornerRadius = 5
        self.delayLabel.textColor = UIColor.white
        self.hosterLabel.textColor = UIColor.white
        contentView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initialize(hosterAddress:String){
        self.hosterLabel.text = hosterAddress
        self.delayLabel.text = "999ms"
    }
    
    public func updateStatus(delay:Double){
        let delayInt = Int(delay)
        if delayInt <= 40{
            self.delayIconView.image = UIImage(named: "signal_2")
        }
        else if delayInt <= 100{
            self.delayIconView.image = UIImage(named: "signal_1")
        }
        else{
            self.delayIconView.image = UIImage(named: "signal_0")
        }
        if delayInt < 999{
            self.delayLabel.text = "\(delayInt)ms"
        }
        else{
            self.delayLabel.text = "999ms"
        }
    }
    
}
