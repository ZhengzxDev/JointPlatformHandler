//
//  CUNavigationView.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/6.
//

import UIKit


protocol JtNavigationViewDelegate:NSObjectProtocol{
    
    func jtNavigationViewOnPressBack()
    
}

class JtNavigationView: UIView,NibLoadable {
    
    
    weak var delegate:JtNavigationViewDelegate?
    
    private var contentView:UIView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIImageView!
    private var tapRec:UITapGestureRecognizer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentView = loadFromNib()
        self.contentView?.backgroundColor = UIColor.clear
        self.addSubview(contentView!)
        contentView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.isUserInteractionEnabled = true
        tapRec = UITapGestureRecognizer(target: self, action: #selector(onPressBack))
        backButton.addGestureRecognizer(tapRec!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func onPressBack(){
        delegate?.jtNavigationViewOnPressBack()
    }
    

}
