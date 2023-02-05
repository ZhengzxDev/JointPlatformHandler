//
//  CUTabTransAnimator.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/8/15.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CUTabTransAnimator:NSObject,UIViewControllerAnimatedTransitioning{

    private let animationDuration:TimeInterval = 0.2
    
    private let toFrameOffsetX:CGFloat = 50
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromeVc = transitionContext.viewController(forKey: .from),
              let toVc = transitionContext.viewController(forKey: .to) else { return }
        
        guard let tabVc = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
            let fromIndex = tabVc.viewControllers?.firstIndex(where: { $0 == fromeVc}),
            let toIndex = tabVc.viewControllers?.firstIndex(where: { $0 == toVc}) else { return }
        
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        
        let fromViewFrame : CGRect = fromView.frame
        let toViewFrame : CGRect = toView.frame
          
        /*var offSet : CGVector?
        if toIndex > fromIndex {
            offSet = CGVector(dx: -1, dy: 0)
        }else{
            offSet = CGVector(dx: 1, dy: 0)
        }
        
        guard let animOffSet = offSet else { return }*/
        //fromView.frame = fromFrame
        
        /*let ofDx : CGFloat = animOffSet.dx
        let ofDy : CGFloat = animOffSet.dy
        toView.frame = toViewFrame.offsetBy(dx: toViewFrame.size.width * ofDx * -1, dy: toViewFrame.size.height * ofDy * -1)
        transitionContext.containerView.addSubview(toView)
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: transitionDuration, animations: {
            fromView.frame = fromViewFrame.offsetBy(dx: fromViewFrame.size.width * ofDx * 1, dy: fromViewFrame.size.height * ofDy * 1)
            toView.frame = toViewFrame
            fromView.alpha = 0
        }) { (_) in
            fromView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }*/
        
        
        var direction:CGFloat = 0
        if toIndex > fromIndex{
            direction = 1
        }
        else{
            direction = -1
        }
        
        
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        toView.frame = toViewFrame.offsetBy(dx: toFrameOffsetX * direction, dy: 0)
        toView.alpha = 0
        
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.backgroundColor = StyleConfig.Colors.background
        
        //print(fromeVc.view.backgroundColor)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveLinear) {
            [weak self] in
            guard let strongSelf = self else { return }
            fromView.frame = fromViewFrame.offsetBy(dx: strongSelf.toFrameOffsetX * -direction, dy: 0)
            toView.frame = toViewFrame
            
        } completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        UIView.animate(withDuration: transitionDuration/2, delay: 0, options: .curveLinear) {
            toView.alpha = 1
        } completion: { (_) in
            
        }
        
        
        
        
        
        
        //let groupAnim = CAAnimationGroup()
        
        //let translateAnim = CABasicAnimation(keyPath: "transform.translation.x")
        //translateAnim.toValue = ofDx * toFrameOffsetX
        //translateAnim.beginTime
        
        //let alphaAnim = CABasicAnimation(keyPath: "opacity")
        //alphaAnim.toValue = 1
        
        //groupAnim.animations = [translateAnim,alphaAnim]
        //groupAnim.isRemovedOnCompletion = false
        //groupAnim.fillMode = .forwards
        

        
    }
}
