//
//  PriceLayer.swift
//  anim1
//
//  Created by 宋恒 on 2015/11/14.
//  Copyright © 2015年 宋恒. All rights reserved.
//

import UIKit

class PriceLayer: CALayer {
    override func drawInContext(ctx: CGContext) {
        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        
        CGContextStrokeRect(ctx, bounds)
        CGContextFillRect(ctx, bounds)
        
        // ---test
        
        CGContextMoveToPoint(ctx, 0, 0)
        CGContextMoveToPoint(ctx, 2.5, 2.5)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextStrokePath(ctx)
    }
}
