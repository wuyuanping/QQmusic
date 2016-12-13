//
//  YPMusicItem.swift
//  QQMusic
//
//  Created by 吴园平 on 27/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit

class YPMusicItem: NSObject {
    ///歌曲名称
    var name: String = ""
    /// MP3文件的名称
    var filename : String = ""
    /// 歌词文件的名称
    var lrcname : String = ""
    /// 歌手的名称
    var singer : String = ""
    /// 封面的图片名称
    var icon : String = ""
    
    ///自定义构造方法：字典转模型
    init(dic: [String: Any]) {
        super.init()
        setValuesForKeys(dic)
    }
    //取消报错
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}

}
