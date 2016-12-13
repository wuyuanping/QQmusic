//
//  YPLrcTools.swift
//  QQMusic
//
//  Created by 吴园平 on 28/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit

class YPLrcTools: NSObject {

}

extension YPLrcTools{
    //定义一个：传入歌曲名字，返回"行模型数组"的函数,一般定义类方法
    class func parseLrc(_ lrcName: String) -> [YPLrcLineItem]?{
        // 1.获取路径
        guard let path = Bundle.main.path(forResource: lrcName, ofType: nil) else {
            return nil
        }
        
        // 2.读取路径中的内容
        guard let totalLrcString = try? String(contentsOfFile: path) else {
            return nil
        }
        //3.对字符串进行分割
            //歌词文件本来就是是一行一行的，将每一行存入数组
        let LrcLineString = totalLrcString.components(separatedBy: "\n")
        var lrcLines: [YPLrcLineItem] = [YPLrcLineItem]() //!!!
        for lrcLineStr in LrcLineString {
        
            //3.1过滤掉不需要的行数包括空行
            if lrcLineStr.contains("[ti:") || lrcLineStr.contains("[ar:") || lrcLineStr.contains("[al:") || !lrcLineStr.contains("["){
                continue //跳过
            }
            //3.2取出歌词
            let lrcLineModel = YPLrcLineItem(lrcLineString: lrcLineStr)
            lrcLines.append(lrcLineModel)
        }
        return lrcLines
    }

}
