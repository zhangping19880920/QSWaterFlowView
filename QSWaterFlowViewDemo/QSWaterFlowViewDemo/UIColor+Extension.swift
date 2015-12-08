//
//  UIColor+Extension.swift
//  GZWeibo05
//
//  Created by zhangping on 15/10/29.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

// 扩展UIColor的功能.
extension UIColor {
    
    /// 返回一个随机色
    class func randomColor() -> UIColor {
        return UIColor(red: randomValue(), green: randomValue(), blue: randomValue(), alpha: 1)
    }
    
    /// 随机 0 - 1 的值
    private class func randomValue() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / 255
    }
}
