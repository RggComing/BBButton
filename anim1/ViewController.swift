//
//  ViewController.swift
//  anim1
//
//  Created by 宋恒 on 2015/11/13.
//  Copyright © 2015年 宋恒. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let button = UIButton(frame: CGRectMake(100, 100, 80, 40))
    
    let backView = UIView(frame:UIScreen.mainScreen().bounds)
    
    private lazy var boomLayer = BoomLayer()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackView()
        setButton()
        
        view.backgroundColor = UIColor.blackColor()
    }
    
    //  隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    //  設置Button基本參數
    private func setButton(){
        button.center = view.center
        
        button.setTitle("敢点嘛?!", forState: UIControlState.Normal)
        
        button.addTarget(self, action: "buttonWillDie", forControlEvents: UIControlEvents.TouchUpInside)
        
        backView.addSubview(button)
        
        boomLayer.frame = button.bounds
        button.layer.addSublayer(boomLayer)
        
        //  重新繪製以調用layer的draw方法
        boomLayer.setNeedsDisplay()
    }
    
    //  设置伪view
    private func setBackView(){
        view.addSubview(backView)
        
        backView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
    }
    
    //  按钮点击监听方法
    @objc private func buttonWillDie() {
        print("即将爆炸...")
        
        button.setTitle("真点啊!!!", forState: UIControlState.Normal)
        
        //  你摇我也摇
        let rockAnim = CAKeyframeAnimation(keyPath: "position.x")
        rockAnim.duration = 0.001
        rockAnim.repeatCount = 2.5 / 0.001
        rockAnim.values = [view.center.x + 5.0,view.center.x - 5.0]
        
        backView.layer.addAnimation(rockAnim, forKey: "groupAnim")
        
        boomLayer.needClean = true
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.6 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            self.button.setTitle("还敢点??", forState: UIControlState.Normal)
        })
    }

}

