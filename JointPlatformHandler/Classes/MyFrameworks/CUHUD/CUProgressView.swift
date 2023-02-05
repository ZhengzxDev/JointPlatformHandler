//
//  CUProgressView.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/8/30.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUProgressView: UIView {

         
    
    private var _lineWidth:CGFloat = 4
    private var _trackColor:UIColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0,alpha: 1)
    private var _progressColor = StyleConfig.Colors.theme
    private var _strokeLength:CGFloat = 0.35

    //进度槽
    let trackLayer = CAShapeLayer()
    //进度条
    let progressLayer = CAShapeLayer()
    //进度条路径（整个圆圈）
    let path = UIBezierPath()
    
    private var progressStrokeEnd:CGFloat = 0
    
    private var trackStrokeEnd:CGFloat = 1
     
    //当前进度
    @IBInspectable var progress: Int = 0 {
        didSet {
            if progress > 100 {
                progress = 100
            }else if progress < 0 {
                progress = 0
            }
        }
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
     
    override func draw(_ rect: CGRect) {
        //获取整个进度条圆圈路径
        
        if path.isEmpty{
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                        radius: bounds.size.width/2 - self._lineWidth,
            startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        }
         
        //绘制进度槽
        trackLayer.frame = bounds
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = self._trackColor.cgColor
        trackLayer.lineWidth = self._lineWidth
        trackLayer.path = path.cgPath
        trackLayer.strokeStart = 0
        trackLayer.strokeEnd = self.trackStrokeEnd
        if !(layer.sublayers?.contains(trackLayer) ?? false){
            layer.addSublayer(trackLayer)
        }
        //绘制进度条
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = self._progressColor.cgColor
        progressLayer.lineWidth = self._lineWidth
        progressLayer.path = path.cgPath
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progressStrokeEnd
        //progressLayer.lineCap = .round
        if !(layer.sublayers?.contains(progressLayer) ?? false){
            layer.addSublayer(progressLayer)
        }
    }
    
     
    //设置进度（可以设置是否播放动画）
    func setProgress(_ pro: Int,animated anim: Bool) {
        setProgress(pro, animated: anim, withDuration: 0.55)
    }
     
    //设置进度（可以设置是否播放动画，以及动画时间）
    func setProgress(_ pro: Int,animated anim: Bool, withDuration duration: Double) {
        progress = pro
        //进度条动画
        CATransaction.begin()
        CATransaction.setDisableActions(!anim)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut))
        CATransaction.setAnimationDuration(duration)
        
        progressLayer.strokeEnd = CGFloat(progress)/100.0
        CATransaction.commit()
        
        
        
        
    }
    
    func loopAnim(start:Bool){
        
        
        if start{
            //progressLayer.removeAllAnimations()
            progressLayer.strokeStart = 0
            progressLayer.strokeEnd = _strokeLength

            progressStrokeEnd = _strokeLength
            
            
            /*let startAnim = CABasicAnimation(keyPath: "strokeStart")
            startAnim.fromValue = 0
            startAnim.toValue = 0.5
            startAnim.duration = 1.2
            startAnim.repeatCount = Float.greatestFiniteMagnitude
            startAnim.autoreverses = true
            startAnim.fillMode = .forwards
            if progressLayer.animation(forKey: "strokeStartAnim") == nil{
                progressLayer.add(startAnim, forKey: "strokeStartAnim")
            }*/
            self.setNeedsDisplay()

            
            let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnim.fromValue = 0
            rotationAnim.toValue = Double.pi * 2
            rotationAnim.duration = 1
            rotationAnim.repeatCount = Float.greatestFiniteMagnitude
            rotationAnim.autoreverses = false
            rotationAnim.fillMode = .forwards
            rotationAnim.isRemovedOnCompletion = false
            if progressLayer.animation(forKey: "rotationAnim") == nil {
                
                progressLayer.add(rotationAnim, forKey: "rotationAnim")
            }
            //print(progressLayer.animationKeys())
            
        }
        else{
            
            progressLayer.removeAllAnimations()
        }

    }
     
    //将角度转为弧度
    fileprivate func angleToRadian(_ angle: Double)->CGFloat {
        return CGFloat(angle/Double(180.0) * Double.pi)
    }
    
    
    public func setStroke(_ color:UIColor){
        self._progressColor = color
    }
    
    public func setTrack(_ color:UIColor){
        self._trackColor = color
    }
    
    public func setStroke(_ width:CGFloat){
        self._lineWidth = width
    }
    
    public func setTrack(_ strokeEnd:CGFloat){
        self.trackStrokeEnd = strokeEnd
    }

    public func setProgress(_ strokeEnd:CGFloat){
        self.progressStrokeEnd = strokeEnd
    }
    
    public func setStroke(length:CGFloat){
        self._strokeLength = length
    }

}
