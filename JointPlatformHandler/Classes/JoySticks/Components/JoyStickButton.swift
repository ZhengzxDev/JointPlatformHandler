//
//  JoyStickButton.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit

class JoyStickButton: UIView,JoyStickComponent {
    
    var comTag: Int! = 0
    var configName: String! = ""
    
    var defaultSize: CGSize{
        get{
            return CGSize(width: 50, height: 50)
        }
    }
    
    var maxSizeMultiper: CGFloat{
        get{
            return 1.5
        }
    }
    
    var typeString: String{
        get{
            return "button"
        }
    }
    
    var layoutDescription: String = ""
    
    var attachedDatas: [String : Any] = [:]
    
    private weak var delegate:GameJoyStickDelegate?
    
    private weak var layoutView:JoyStickLayoutView?
    
    private var ratio:CGFloat = 1
    
    private var buttonView:UIView = UIView()
    
    private var buttonImageView:UIImageView?
    
    private var tapRec:UITapGestureRecognizer = UITapGestureRecognizer()
    
    private var imageViewRatio:Double = 0.7

    
    func initialize(_ layoutView:JoyStickLayoutView){
        
        self.layoutView = layoutView
        
        /*guard let buttonConfig = config as? [String:Any] else { return }
        guard let imageKey = buttonConfig["imageName"] as? String else { return }
        
        if let configImageRatio = buttonConfig["imageRatio"] as? Double{
            self.imageViewRatio = configImageRatio
        }*/
        guard let imageKey = attachedDatas["imageName"] as? String else { return }
        if let imageData = layoutView.controller?.asset(for: imageKey) as? Data{
            guard let image = UIImage(data: imageData) else { return }
            buttonImageView = UIImageView(image: image)
            buttonImageView?.contentMode = .scaleAspectFit
            buttonView.addSubview(buttonImageView!)
            buttonImageView!.snp.makeConstraints { make in
                make.size.equalToSuperview().multipliedBy(imageViewRatio)
                make.center.equalToSuperview()
            }
        }

    }
    
    func setDelegate(_ target: GameJoyStickDelegate) {
        self.delegate = target
    }
    
    func setRatio(_ value: CGFloat) {
        self.ratio = value
    }
    
    func setEnable(_ value: Bool) {
        self.isUserInteractionEnabled = value
    }
    
    
    func getView() -> UIView {
        return self
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let buttonSize:CGFloat = min(rect.height,rect.width) * ratio
        buttonView.frame = CGRect(x: (rect.width-buttonSize)/2, y: (rect.height-buttonSize)/2, width: buttonSize, height: buttonSize)
        buttonView.layer.cornerRadius = buttonSize/2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(buttonView)
        buttonView.addGestureRecognizer(tapRec)
        buttonView.backgroundColor = UIColor.white
        tapRec.addTarget(self, action: #selector(onPressButton))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func onPressButton(){
        delegate?.joyStick?(onButtonPressd: self)
    }
}
