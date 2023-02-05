//
//  JoyStickKnob.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit

class JoyStickKnob: UIView,JoyStickComponent {
    

    var comTag: Int! = 0
    
    var configName: String! = ""
    
    var defaultSize: CGSize{
        get{
            return CGSize(width: 130, height: 130)
        }
    }
    
    var maxSizeMultiper: CGFloat{
        get{
            return 1.5
        }
    }
    
    var typeString: String{
        get{
            return "knob"
        }
    }
    
    var layoutDescription: String = ""
    
    var attachedDatas: [String : Any] = [:]
    
    private let outlineStroke:CGFloat = 3
    
    private let outlineColor:UIColor = UIColor.white
    
    private let knobDotSize:CGSize = CGSize(width: 50, height: 50)
    
    private let knobDotColor:UIColor = UIColor.white
    
    private var ratio:CGFloat = 1
    
    private var pathLayer:CAShapeLayer?
    
    private weak var delegate:GameJoyStickDelegate?
    
    private weak var stick:GameJoyStick?
    
    private lazy var knobDot:UIView = {
        let view = UIView()
        view.layer.cornerRadius = knobDotSize.width/2
        view.backgroundColor = knobDotColor
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var panRec:UIPanGestureRecognizer?
    
    private var dotBaseFrame:CGRect!
    
    private var dotBaseCenter:CGPoint{
        get{
            return CGPoint(x: dotBaseFrame.midX, y: dotBaseFrame.midY)
        }
    }
    
    private var circleRectEdge:CGFloat!
    
    private var beganInCircle:Bool = false
    
    private var isEnabled:Bool = true
    
    private var dataVolumeOptimization:Bool = false
    
    private var ignoreNextAction:Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(knobDot)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setRatio(_ value:CGFloat){
        self.ratio = value
    }
    
    func setStick(_ stick: GameJoyStick) {
        self.stick = stick
    }
    
    func getView() -> UIView {
        return self
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let centerX = rect.size.width/2
        let centerY = rect.size.height/2
        circleRectEdge = min(rect.size.width,rect.size.height) * ratio
        let boundingRect = CGRect(x: centerX - circleRectEdge/2, y: centerY - circleRectEdge/2, width: circleRectEdge, height: circleRectEdge)
        let oribitPath:CGPath = UIBezierPath(ovalIn: boundingRect).cgPath
        
        if pathLayer == nil{
            pathLayer = CAShapeLayer()
        }
        pathLayer?.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        pathLayer?.path = oribitPath
        pathLayer?.fillColor = nil
        pathLayer?.lineWidth = outlineStroke
        pathLayer?.strokeColor = outlineColor.cgColor
        
        if pathLayer!.superlayer == nil{
            self.layer.addSublayer(pathLayer!)
        }
        dotBaseFrame = CGRect(x: (rect.width-knobDotSize.width)/2, y: (rect.height-knobDotSize.height)/2, width: knobDotSize.width, height: knobDotSize.height)
        knobDot.frame = dotBaseFrame
    }
    
    func initialize(_ layoutView: JoyStickLayoutView) {
        panRec = UIPanGestureRecognizer(target: self, action: #selector(onPanKnobDot(_:)))
        panRec?.maximumNumberOfTouches = 1
        panRec?.minimumNumberOfTouches = 1
        self.addGestureRecognizer(panRec!)
        
        if let modeString = attachedDatas["mode"] as? String{
            if modeString == "optimized"{
                self.dataVolumeOptimization = true
            }
        }
    }
    
    
    func setDelegate(_ target: GameJoyStickDelegate) {
        self.delegate = target
    }
    
    func setEnable(_ value: Bool) {
        self.isEnabled = value
        self.isUserInteractionEnabled = value
    }
    
    @objc func onPanKnobDot(_ recognizer:UIPanGestureRecognizer){
        guard self.isEnabled else { return }
        if recognizer.state == .began{
            beganInCircle = false
            let location = recognizer.location(in: self)
            let offsetX = location.x-dotBaseCenter.x
            let offsetY = dotBaseCenter.y-location.y
            let dist = offsetX * offsetX + offsetY * offsetY
            let radius = circleRectEdge/2
            if isInCircle(point: location, center: dotBaseCenter, radius: circleRectEdge/2){
                beganInCircle = true
                knobDot.frame = CGRect(x: location.x-dotBaseFrame.width/2, y: location.y-dotBaseFrame.height/2, width: dotBaseFrame.width, height: dotBaseFrame.height)
                delegate?.joyStick?(knob: self, onMoved: CGVector(dx: offsetX, dy: offsetY).normalized, offsetDegree: min(1,sqrt(dist)/radius))
            }
        }
        else if recognizer.state == .changed{
            guard beganInCircle else { return }
            let location = recognizer.location(in: self)
            
            let offsetX = location.x-dotBaseCenter.x
            let offsetY = dotBaseCenter.y-location.y
            let dist = offsetX * offsetX + offsetY * offsetY
            let radius = circleRectEdge/2
            if dist <= radius * radius {
                knobDot.frame = CGRect(x: location.x-dotBaseFrame.width/2, y: location.y-dotBaseFrame.height/2, width: dotBaseFrame.width, height: dotBaseFrame.height)
            }
            else{
                let yRatio:CGFloat = -offsetY/sqrt(dist)
                var fixedY =  yRatio * radius
                fixedY += dotBaseCenter.y
                let xRatio:CGFloat = offsetX/sqrt(dist)
                var fixedX = xRatio * radius
                fixedX += dotBaseCenter.x
                knobDot.frame = CGRect(x: fixedX-dotBaseFrame.width/2, y: fixedY-dotBaseFrame.height/2, width: dotBaseFrame.width, height: dotBaseFrame.height)
            }
            if dataVolumeOptimization{
                if ignoreNextAction{
                    ignoreNextAction = false
                    return
                }
                delegate?.joyStick?(knob: self, onMoved: CGVector(dx: offsetX, dy: offsetY).normalized, offsetDegree: min(1,sqrt(dist)/radius))
                ignoreNextAction = true
            }
            else{
                delegate?.joyStick?(knob: self, onMoved: CGVector(dx: offsetX, dy: offsetY).normalized, offsetDegree: min(1,sqrt(dist)/radius))
            }
            
        }
        else if recognizer.state == .ended{
            knobDot.frame = dotBaseFrame
            delegate?.joyStick?(knob: self, onMoved: CGVector.zero, offsetDegree: 0)
        }

    }
    
    
    func isInCircle(point:CGPoint,center:CGPoint,radius:CGFloat) -> Bool{
        let offsetX = point.x-center.x
        let offsetY = point.y-center.y
        let dist = offsetX * offsetX + offsetY * offsetY
        return dist <= radius * radius
    }

}
