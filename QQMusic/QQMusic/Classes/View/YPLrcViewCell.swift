//
//  YPLrcViewCell.swift
//  QQMusic
//
//  Created by 吴园平 on 28/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit

class YPLrcViewCell: UITableViewCell {
    
    lazy var  lrcLabel:YPLrcLabel = YPLrcLabel()
    
    //不管是注册还是重利用cell，都会调用initWithStyle => 重写父类构造方法
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lrcLabel) //懒加载
        
        //注意：cell也是有背景色的
        backgroundColor = UIColor.clear
        //取消选中样式
        selectionStyle = .none
        
        lrcLabel.textColor = UIColor.white
        lrcLabel.font = UIFont.systemFont(ofSize: 14)
        lrcLabel.textAlignment = .center
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //只要添加了子控件就要布局
        lrcLabel.sizeToFit()
        lrcLabel.center = contentView.center //控件居中
    }
    
    
}
