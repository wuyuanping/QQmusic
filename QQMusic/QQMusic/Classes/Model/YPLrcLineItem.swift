//
//  YPLrcLineItem.swift
//  QQMusic
//
//  Created by 吴园平 on 28/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit

class YPLrcLineItem: NSObject {
    
    /// 一行歌词
    var lrcText: String = ""
    
    /// 一行歌词从整个歌曲头部开始到该句开始的时间（TimeInterval为Double类型）
    var lrcLineTime: TimeInterval = 0
    
    //Swift：类中自定义构造函数必须初始化所有非可选属性
    init (lrcLineString: String){ //传入一行包含时间的歌词例如： [00:35.89]你所有承诺　虽然都太脆弱
        
        let LrcLineStrs = lrcLineString.components(separatedBy: "]") //返回数组
        lrcText = LrcLineStrs[1]
        
        let lrcTime = LrcLineStrs[0].components(separatedBy: "[")[1]
        
        let min =  Double(lrcTime.components(separatedBy: ":")[0])
        let sec = Double(lrcTime.components(separatedBy: ":")[1].components(separatedBy: ".")[0])
        let haomiao = Double(lrcTime.components(separatedBy: ".")[1])
        
        lrcLineTime = min! * 60 + sec! + haomiao! * 0.01
    
    }
    
}
