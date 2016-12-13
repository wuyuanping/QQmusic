//
//  YPLrcLabel.swift
//  QQMusic
//
//  Created by 吴园平 on 28/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit

class YPLrcLabel: UILabel {
    //自定义label才可以画颜色
    
    var progress: Double = 0{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //设置颜色
        UIColor.green.set()
        
        //设置渐变文字
        let drawRect = CGRect(x: 0, y: 0, width: rect.width * CGFloat(progress), height: rect.height)
        // S : 填充的透明度  --> 1.0
        // Da : 原有的透明度  --> 0.0/1.0
        // /* R = S*(1 - Da) */ 填充非文字
        // case sourceIn /* R = S*Da */ 填充文字，推荐
        UIRectFillUsingBlendMode(drawRect, .sourceIn) // 突破口！！逆推
        
    }

}
