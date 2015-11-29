//
//  BoomLayer.swift
//  anim1
//
//  Created by 宋恒 on 2015/11/13.
//  Copyright © 2015年 宋恒. All rights reserved.
//

import UIKit

class BoomLayer: CALayer {
    
    var needClean = false{
        didSet{
            setNeedsDisplay()
        }
    }
    
    //  碎片layer數組
    private lazy var prices = [PriceLayer]()

    override func drawInContext(ctx: CGContext) {
        
        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
        
        CGContextFillRect(ctx, bounds)
        
        //  清除layer的方法,如果Button被点击,就清空layer的内容
        if needClean {
            
            sublayers = []
            prices = []
            
            //  预备爆炸视图
            animGoingToBoom()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {[weak self] () -> Void in
                //  清空之前内容
                CGContextClearRect(ctx, self?.bounds ?? CGRectMake(0, 0, 0, 0))
                
                //  准备碎片layer
                self?.prepareForPriceLayer()
            })
        }
    }
    
    //  准备爆炸碎片
    private func prepareForPriceLayer(){
        let priceWidth:CGFloat = 2.5
        
        //  行
        let lineNum = Int(frame.height / priceWidth)
        
        //  列
        let rowNum = Int(frame.width / priceWidth)
        
        //  布局priceLayer
        for(var i=0 ; i < lineNum * rowNum ; i++){
            let priceLayer = PriceLayer()
            
            let x = CGFloat(Int(i % rowNum)) * priceWidth
            
            let y = CGFloat(Int(i / rowNum)) * priceWidth
            
            priceLayer.frame = CGRectMake(x, y, priceWidth + 0.2, priceWidth + 0.2)
            
            addSublayer(priceLayer)
            
            prices.append(priceLayer)
            
            priceLayer.setNeedsDisplay()
            }
        }
    
    private func animGoingToBoom(){
        //  组动画
        let groupAnim = CAAnimationGroup()
        groupAnim.duration = 2.5

        groupAnim.delegate = self
        
        //  ------正在膨大
        let biggerAnim = CABasicAnimation(keyPath: "transform.scale")
        biggerAnim.duration = groupAnim.duration
        biggerAnim.toValue = 1.3
        biggerAnim.removedOnCompletion = false
        
        //  ------正在摇晃
        let rockAnimX = CABasicAnimation(keyPath: "position.x")
        rockAnimX.byValue = 3
        rockAnimX.duration = 0.001
        rockAnimX.repeatCount = MAXFLOAT
        
        let rockAnimY = CABasicAnimation(keyPath: "position.y")
        rockAnimY.byValue = 3
        rockAnimY.duration = 0.001
        rockAnimY.repeatCount = MAXFLOAT
        
        //  ------正在变淡
        let easeOutAnim = CABasicAnimation(keyPath: "opacity")
        easeOutAnim.toValue = 0.5
        
        //  ------添加到组动画
        groupAnim.animations = [biggerAnim,easeOutAnim,rockAnimX]
        
        //  开始组动画
        addAnimation(groupAnim, forKey: "groupAnim")
        
    }
    
    override func animationDidStart(anim: CAAnimation) {
        print("begin")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        print("end")
        
        //  闪一下
        let window = UIApplication.sharedApplication().windows.last
        
        window?.layer.addSublayer(flashlayer)
        
        //  -----减淡动画
        let coldDownAnim = CABasicAnimation(keyPath: "opacity")
        coldDownAnim.fromValue = 1
        coldDownAnim.toValue = 0.3
        coldDownAnim.duration = 2
        
        flashlayer.addAnimation(coldDownAnim, forKey: "coldDownAnim")
        
        //  -----飞吧,碎片
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_global_queue(0, 0)) { () -> Void in
            print(self.prices.count)
            self.letsBoom()
        }
    }
    
    private func letsBoom(){
        
        //  遍歷layer數組,讓每個layer計算各自的目標點
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            let px = self.position.x
            let py = self.position.y
            
            for priceLayer in self.prices{
                //  計算目標點
                var targetX = CGFloat(0)
                var targetY = CGFloat(0)
                
                //  左上
                if priceLayer.position.x < px && priceLayer.position.y < py{
                    targetX = -py/(py - priceLayer.position.y) * priceLayer.position.x - 10.0
                    targetY = -px/(px - priceLayer.position.x) * priceLayer.position.y - 10.0
                }
                
                //  左下
                if priceLayer.position.x < px && priceLayer.position.y > py{
                    targetX = py/(py - priceLayer.position.y) * priceLayer.position.x
                    targetY = px/(px - priceLayer.position.x) * priceLayer.position.y
                    
                }
                
                // 右上
                if priceLayer.position.x > px && priceLayer.position.y < py{
                    targetX = py/(py - priceLayer.position.y) * priceLayer.position.x
                    targetY = px/(px - priceLayer.position.x) * priceLayer.position.y
                }
                
                //  右下
                if priceLayer.position.x > px && priceLayer.position.y > py{
                    targetX = -py/(py - priceLayer.position.y) * priceLayer.position.x
                    targetY = -px/(px - priceLayer.position.x) * priceLayer.position.y
                }
                
                
                //  组动画
                let groupAnim = CAAnimationGroup()
                groupAnim.duration = 1
                
                //  ---飞翔动画
                let flyAnim = CAKeyframeAnimation(keyPath: "position")
                flyAnim.values = [NSValue(CGPoint: priceLayer.position) as AnyObject,NSValue(CGPoint: CGPointMake(targetX * 2, targetY * 2)) as AnyObject]
                flyAnim.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
                
                //  ---淡出
                let easeOutAnim = CABasicAnimation(keyPath: "opacity")
                easeOutAnim.toValue = 0.4
                
                //  ---旋转
                let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.z")
                rotateAnim.toValue = (M_PI * 2) * Double(random() % 10 + 3)
                
                //  ---放大
                let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
                scaleAnim.toValue = 1.3
                
                groupAnim.animations = [flyAnim,easeOutAnim,rotateAnim,scaleAnim]
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    priceLayer.addAnimation(groupAnim, forKey: "flyAnim")
                })
            }
        }
    }
        
    
    /// 闪瞎你的layer
    private lazy var flashlayer:CALayer = {
        let flashLayer = CALayer()
        
        flashLayer.backgroundColor = UIColor.whiteColor().CGColor
        
        flashLayer.frame = (UIScreen.mainScreen().bounds)
        
        flashLayer.opacity = 0
        
        return flashLayer
    }()
}

//  待研究
extension BoomLayer{
    func desert(){
//        //  -----繪製文字
//        CGContextMoveToPoint(ctx, 0, 0)
//        CGContextAddLineToPoint(ctx, 100, 100)
//        
//        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
//        //        CGContextSetTextMatrix(<#T##c: CGContext?##CGContext?#>, <#T##t: CGAffineTransform##CGAffineTransform#>)
//        CGContextSetTextDrawingMode(<#T##c: CGContext?##CGContext?#>, <#T##mode: CGTextDrawingMode##CGTextDrawingMode#>)
//        CGContextSetTextPosition(<#T##c: CGContext?##CGContext?#>, <#T##x: CGFloat##CGFloat#>, <#T##y: CGFloat##CGFloat#>)
//        
//        CGContextSetLineWidth(ctx, 0.25)
//        
//        ("文字" as NSString).drawInRect(bounds, withAttributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)])
//        CGContextDrawPath(ctx, CGPathDrawingMode.Stroke)

    }
}
