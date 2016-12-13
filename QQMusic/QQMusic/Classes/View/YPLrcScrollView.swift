//
//  YPLrcScrollView.swift
//  QQMusic
//
//  Created by 吴园平 on 28/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit
private let klrcCellID = "klrcCellID"

protocol LrcScrollViewDelegate: class {
    //将当前播放歌词和进度传出去
    func LrcScrollView(_ LrcScrollView: YPLrcScrollView,lrcText: String,progress: Double)
}

class YPLrcScrollView: UIScrollView {
    
    //思路：scrollview里嵌套tableView
     // MARK: - 内部属性
    fileprivate lazy var tableView: UITableView = UITableView()
    fileprivate var lrcLines:[YPLrcLineItem]?
    fileprivate var currentLineIndex: Int = 0
    
     // MARK: - 代理属性
    weak var lrcDelegate: LrcScrollViewDelegate?
    
    
     // MARK: - 对外属性
    var lrcName: String = ""{ //外界传入歌曲名字
        didSet{
        //当切换歌曲的时候，换设置内容偏移量为下降一半，系统初始化("")时不会调用；在布局子控件之前调用，故第一次设置内容偏移量不会有效
            tableView.setContentOffset(CGPoint(x: 0, y: -bounds.height * 0.5 ), animated: true)
            //整首歌转成“行模型”
            lrcLines = YPLrcTools.parseLrc(lrcName)
            tableView.reloadData()
            currentLineIndex = 0 //每一次换歌，都要从第一句开始
        }
    }
    var currentTime: TimeInterval = 0 {
        didSet{
            //思路：得到当前时间，根据行模型时间数据 判断 具体显示哪句歌词
            
            //1.判断行模型是否有数据
            guard let lrcLine = lrcLines else {return}
            //2.遍历所有的行模型
            let count = lrcLine.count
            for i in 0..<count {
                //1.取出当前句的歌词
                let currentLineLrc = lrcLine[i]
                //2.取出下一句的歌词
                let nextIndex = i + 1
                if nextIndex > count - 1 {
                    continue
                }
                let nextLineLrc = lrcLine[nextIndex]
                
                //3.滚动条件: 大于i位置的歌词时间,并且小于i+1位置的歌词时间，即刚进入下一句,则下一句放到i位置显示,注意：1.i不等于默认值时才会滚动；2.每一句歌词lrcLineTime时间都是从歌曲头部开始算起的。
                if currentTime > currentLineLrc.lrcLineTime && currentTime < nextLineLrc.lrcLineTime && i != currentLineIndex {
                    // 1.更新当前i值
                    currentLineIndex = i
                    
                    // 2.刷新当前句和前一句两个indexPath
                    let indexPath = IndexPath(row: i, section: 0)
                    let preIndexPath = IndexPath(row: i - 1, section: 0)
                    tableView.reloadRows(at: [preIndexPath,indexPath], with: .none)
                    
                    // 3.滚动到正确的位置（从底部开始滚）
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
                }
                //4.当在播放同一句歌词时，画颜色进度
                if i == currentLineIndex {
                    // 4.1.获取当前进度(当前句已播时间 / 当前句总时间)
                    let progress = (currentTime - currentLineLrc.lrcLineTime) / (nextLineLrc.lrcLineTime - currentLineLrc.lrcLineTime)
                    
                    // 4.2.取出对应的Cell开始画进度
                    let indexPath = IndexPath(row: i, section: 0)
                    guard let currentCell = tableView.cellForRow(at: indexPath) as? YPLrcViewCell else {continue}
                    currentCell.lrcLabel.progress = progress
                    
                    //4.3通知代理,将当前播放歌词和进度传出去
                    lrcDelegate?.LrcScrollView(self,lrcText: currentLineLrc.lrcText,progress: progress)
                }
            
            }
            
        }
    
    }
    
    override func awakeFromNib() {
        //从xib或storyboard中加载就一定会调用
        //设置UI
        setupUI()
    }
}

// MARK: - 设置UI
extension YPLrcScrollView{
    fileprivate func setupUI(){
        addSubview(tableView) //懒加载tableView
        tableView.backgroundColor = UIColor.clear
        tableView.register(YPLrcViewCell.self, forCellReuseIdentifier: klrcCellID)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 35
    }
    
    // MARK - 布局子控件
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let x: CGFloat = bounds.width
        let y: CGFloat = 0
        let w: CGFloat = bounds.width
        let h: CGFloat = bounds.height
        
        tableView.frame = CGRect(x: x, y: y, width: w, height: h)
        //设置tableView的内容内边距,顶部和底部可以到中间
        tableView.contentInset = UIEdgeInsets(top: bounds.height * 0.5, left: 0, bottom: bounds.height * 0.5, right: 0)
        //设置内容偏移量，从中间开始
        tableView.setContentOffset(CGPoint(x: 0, y: -bounds.height * 0.5 ), animated: true)
    }
}

// MARK: - 实现数据源方法
extension YPLrcScrollView: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //歌词的行数
        return lrcLines?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: klrcCellID, for: indexPath) as! YPLrcViewCell
        
        //区分当前行和其他行的颜色
        if indexPath.row == currentLineIndex {
            cell.lrcLabel.textColor = UIColor.red
        }else{
            cell.lrcLabel.textColor = UIColor.white
            cell.lrcLabel.progress = 0 //防止进度循环利用
        }
        
        cell.lrcLabel.text = lrcLines?[indexPath.row].lrcText
        return cell
    }

}



























