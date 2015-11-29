//
//  SXRButton.swift
//  anim1
//
//  Created by 宋恒 on 2015/11/14.
//  Copyright © 2015年 宋恒. All rights reserved.
//

import UIKit

class SXRButton: UIButton {

    internal override class func layerClass() -> AnyClass{
        return BoomLayer.classForCoder()
    }

}
