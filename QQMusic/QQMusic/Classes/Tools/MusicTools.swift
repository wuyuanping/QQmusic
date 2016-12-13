//
//  MusicTools.swift
//  播放音乐（工具类抽取）
//
//  Created by 吴园平 on 25/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit
import AVFoundation

class MusicTools { //不用NSObject提供的方法，干脆不继承
    fileprivate static var player: AVAudioPlayer? //类实属，类方法中可以访问类属性
}
// MARK: - 工具类
extension MusicTools{
    //思路：创建工具类，一般提供类方法，注意类方法中只能访问类属性
    
    /// 播放音乐
    class func playMusic(_ musicName : String) {
        // 1.根据传入的名称获取对应的URL
        guard let url = Bundle.main.url(forResource: musicName, withExtension: nil) else { return }
        
        // 2.判断和之前暂停&停止的音乐是否是同一首歌曲
        if player?.url == url {
            player?.play()
            return
        }
        
        // 3.根据URL,创建AVAudioPlayer对象
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        self.player = player
        
        // 4.播放歌曲
        player.play()
    }
    
    /// 停止播放
    class func stopMusic(){
        player?.stop()
        player?.currentTime = 0 //下次直接从0开始播放
    }
    
    /// 暂停播放
    class func pauseMusic(){
        player?.pause()
    }

}

// MARK: - 其他内容的设置（音量/当前显示时间）
extension MusicTools{
    /// 改变音量
    class func changeVolume(_ volume: Float){
        player?.volume = volume
    
    }
    
    /// 设置当前播放时间
    class func setCurrentTime(_ currentTime: TimeInterval){
        player?.currentTime = currentTime
    }
    
    /// 返回当前播放时间
    class func getCurrentTime() -> TimeInterval{
        return player?.currentTime ?? 0
    }
    ///获得总时间
    class func getDuration() -> TimeInterval{
        return player?.duration ?? 0
    }

}

















