//
//  YPPlayingViewController.swift
//  QQMusic
//
//  Created by 吴园平 on 26/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class YPPlayingViewController: UIViewController {
    //控件属性
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var IconImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    @IBOutlet weak var LrcScrollView: YPLrcScrollView!
    @IBOutlet weak var LrcLabel: YPLrcLabel!
    
    @IBOutlet weak var PlayOrPauseBtn: UIButton!
    
    fileprivate var progressTimer: Timer? //防止局部作用域被销毁
    fileprivate var currentMusicIndext = 0
    fileprivate var lrcTimer : CADisplayLink? //一秒60次，更准确监听歌词的滚动
     // MARK: - 懒加载模型属性
    fileprivate lazy var musics: [YPMusicItem] = [YPMusicItem]() //包含初始化和实现 == "{}()"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1.设置UI界面
        setupUI()
        //2.加载数据
        loadMusicData()
        //3.播放歌曲
        startPlayingMusic()
        
        LrcScrollView.delegate = self
    }
    
   
}

// MARK: -设置UI界面
extension YPPlayingViewController{
    fileprivate func setupUI(){
        //1.设置毛玻璃
        setupBlurView()
        //2.设置滑块的图片
        progressSlider.setThumbImage(UIImage(named: "player_slider_playback_thumb"), for: .normal)
        //3.设置IconImageView的圆角
        setupIconViewCons()
        //4.设置LrcScrollView的内容范围(两倍的屏幕宽度)
        LrcScrollView.contentSize = CGSize(width: view.bounds.width * 2, height: 0)
        //5.设置代理
        LrcScrollView.lrcDelegate = self
        
    }
    private func setupBlurView(){
        
        let blurEffect = UIBlurEffect(style:.dark)
        //创建毛玻璃对象
       let blurView = UIVisualEffectView(effect: blurEffect)  //突破口,逆推，技巧：找子类
        blurView.frame = UIScreen.main.bounds
        blurView.autoresizingMask = [.flexibleWidth,.flexibleHeight] //适配
        //将毛玻璃加入背景图片
        bgImageView.addSubview(blurView)
    }
    
    private func setupIconViewCons(){
        //60为图片与屏幕两边间距之和
        IconImageView.layer.cornerRadius = (view.bounds.width - 60) * 0.5
        IconImageView.layer.masksToBounds = true //超出部分减掉
        IconImageView.layer.borderWidth = 8
        IconImageView.layer.borderColor = UIColor.black.cgColor
    
    }
    //设置状态栏属性（默认是有控制器管理）
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

// MARK: -加载数据
extension YPPlayingViewController{
    fileprivate func loadMusicData(){
        //1.获取plist文件路径
        let pathPlist = Bundle.main.path(forResource: "Musics.plist", ofType: nil)
        //2.获取数据
        guard let MusicArr = NSArray(contentsOfFile: pathPlist!) as? [[String : Any]] else {return}
        //3.字典数组转模型数组
        for music in MusicArr{
            musics.append(YPMusicItem(dic: music))
        }
    
    }
}
// MARK: -播放歌曲
extension YPPlayingViewController{
    fileprivate func startPlayingMusic(){
        //1.随机取出某一首歌曲,进行播放
//        let random = arc4random_uniform(UInt32(musics.count))
//        let musicItem = musics[Int(random)]
        
        let musicItem = musics[currentMusicIndext]
        MusicTools.playMusic(musicItem.filename)
        
        //2.改变界面中的内容
        bgImageView.image = UIImage(named: musicItem.icon)
        IconImageView.image = UIImage(named: musicItem.icon)
        songLabel.text = musicItem.name
        singerLabel.text = musicItem.singer
        progressSlider.value = 0
        
        //3.显示歌曲的总时间  例如：250 --> 04:10
        totalTime.text = stringWithTime(MusicTools.getDuration())
        
        //4.添加更新进度的定时器（管理slider和播放时间的进度）
        addProgressTimer()
        
        //5.给IconImageView添加旋转动画
        addRotationAni()
        
        //6.将歌词文件的名称传入到UIScrollView中
        LrcScrollView.lrcName = musics[currentMusicIndext].lrcname
        
        //7.添加歌词的定时器
        removeLrcTimer() //切记先删除之前的，防止换歌出错
        addLrcTimer()
        
    }
    
    fileprivate func stringWithTime(_ Time: TimeInterval) -> String{
        //注意TimeInterval单位是秒
        let min = Int(Time) / 60
        let sec = Int(Time) % 60
        
        return String(format: "%02d:%02d",min,sec)
    }
    
    fileprivate func addRotationAni(){
        //1.创建动画(CABasic/KeyFrame)
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")//z轴旋转
        //2.设置动画属性
        rotationAnim.fromValue = 0
        rotationAnim.toValue = M_PI * 2
        rotationAnim.repeatCount = MAXFLOAT //最大值就相当于无限
        rotationAnim.duration = 30 //秒
        //3.将动画添加到IconImageView的layer上
        IconImageView.layer.add(rotationAnim, forKey: nil)
    }
}

// MARK: - 对定时器进行操作
extension YPPlayingViewController{
    
    fileprivate func addProgressTimer(){
        //每秒更新时间和进度条
        progressTimer = Timer(timeInterval : 1.0, target : self, selector:#selector(updateProgress), userInfo: nil  , repeats: true)
        RunLoop.main.add(progressTimer!, forMode: .commonModes) //切记否则图片旋转相当于改变模式，定时器会失效
    }
    @objc fileprivate func updateProgress(){
   
        currentTime.text = stringWithTime(MusicTools.getCurrentTime())
        progressSlider.value = Float(MusicTools.getCurrentTime() / MusicTools.getDuration())
    }
    
    fileprivate func removeProgressTimer(){
        progressTimer?.invalidate() //销毁
        progressTimer = nil //防止野指针
    }
    
    fileprivate func addLrcTimer(){
        lrcTimer = CADisplayLink(target: self, selector: #selector(updatLrc))
        lrcTimer?.add(to: RunLoop.main, forMode: .commonModes)
    }
    fileprivate func removeLrcTimer(){
        lrcTimer?.invalidate()
        lrcTimer = nil
    }
    @objc fileprivate func updatLrc(){
        //将很准的定时器计算好的播放时间，传给LrcScrollView去根据时间滚动具体歌词
        LrcScrollView.currentTime = MusicTools.getCurrentTime()
    }

}

// MARK: - 对播放进度的控制
extension YPPlayingViewController{
    @IBAction func slideValueChange() {
        //拖动进度条就要立即改变成对应的时间,注意，此时显示的拖动时间是临时的，因为不需要加定时器，不会改变
        //1.获取当前进度对应的时间 TimeInterval = Double
        let time = Double(progressSlider.value) * MusicTools.getDuration()
        //2.显示当前时间
        currentTime.text = stringWithTime(time)
    }
    @IBAction func slideTouchInside() {
        updateCurrentTime()
    }
    
    @IBAction func slideTouchOutSide() {//拖动时在外面松手也要更新时间
        updateCurrentTime()
    }

    @IBAction func slideTouchDown() {//按下去进度条瞬间，移除定时器，因为下一次重新从某一个不确定的点开始
        removeProgressTimer()
    }
        //拖手势，点击进度条，更新时间和进度
    @IBAction func slideTapGes(_ sender: UITapGestureRecognizer) {
        //1.获取手指点击的位置
        let point = sender.location(in: progressSlider)
        //2.计算该位置x对应的比例(注意：x相对于父控件progressSlider)
        let ratio = point.x / progressSlider.frame.width
        //3.根据比例,改变歌曲的进度
        let time = Double(ratio) * MusicTools.getDuration()
        MusicTools.setCurrentTime(time)
        updateProgress()
    }
    
    fileprivate func updateCurrentTime(){
        //1.获取当前进度对应的时间
        let time = Double(progressSlider.value) * MusicTools.getDuration()
        //2.将当前播放时间设置成该时间（注意：松手之后表示开始时间确定了，要加定时器故不是临时显示）
        MusicTools.setCurrentTime(time) //!!!
        //3.将定时器添加进来,实时改变
        addProgressTimer()
    }

}

// MARK: - 上一首/下一首/播放暂停
extension YPPlayingViewController{
    
    @IBAction func previousMusic() {
        switchMusic(isNext: false)
    }
    @IBAction func nextMusic() {
        switchMusic(isNext: true)
    }
    
    @IBAction func PllayOrPauseMusic(_ sender: UIButton) {
        //1.改变当前按钮状态
        sender.isSelected = !sender.isSelected
        //2.根据状态,播放&暂停歌曲
        if sender.isSelected {
            let item = musics[currentMusicIndext]
            MusicTools.playMusic(item.filename)
            //开始动画
            IconImageView.layer.resumeAnim()
        }else{
            MusicTools.pauseMusic()
            //暂停动画
            IconImageView.layer.pauseAnim()
        }
        
    }
    
    private func switchMusic(isNext: Bool){
       
        // 1.更新当前歌曲的下标值

        if isNext {
            currentMusicIndext += 1
            if currentMusicIndext > musics.count - 1 {
                currentMusicIndext = 0
            }
        }else{
            currentMusicIndext -= 1
            if currentMusicIndext < 0 {
                currentMusicIndext = musics.count - 1
            }
        }
        // 2.播放该歌曲
        startPlayingMusic()
        PlayOrPauseBtn.isSelected = true
        IconImageView.layer.resumeAnim()
    }

}

extension YPPlayingViewController: UITableViewDelegate,LrcScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio =  scrollView.contentOffset.x / scrollView.bounds.width
        IconImageView.alpha = 1 - ratio  //逐渐变透明
        LrcLabel.alpha = 1 - ratio
    }
    
    func LrcScrollView(_ LrcScrollView: YPLrcScrollView, lrcText: String, progress: Double) {
        LrcLabel.text = lrcText
        LrcLabel.progress = progress
    }
}

// MARK: - 连续播放
extension YPPlayingViewController :AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            nextMusic()
        }
    }
    
}

// MARK:- 设置锁屏界面的信息
/*
 // MPMediaItemPropertyAlbumTitle
 // MPMediaItemPropertyAlbumTrackCount
 // MPMediaItemPropertyAlbumTrackNumber
 // MPMediaItemPropertyArtist
 // MPMediaItemPropertyArtwork
 // MPMediaItemPropertyComposer
 // MPMediaItemPropertyDiscCount
 // MPMediaItemPropertyDiscNumber
 // MPMediaItemPropertyGenre
 // MPMediaItemPropertyPersistentID
 // MPMediaItemPropertyPlaybackDuration
 // MPMediaItemPropertyTitle
 */
extension YPPlayingViewController {
    func setupLockInfo() {
        // 1.获取锁屏中心
        let centerInfo = MPNowPlayingInfoCenter.default()
        
        // 2.设置信息
        var infoDict = [String : Any]()
        infoDict[MPMediaItemPropertyAlbumTitle] = musics[currentMusicIndext].name
        infoDict[MPMediaItemPropertyArtist] =  musics[currentMusicIndext].singer
        infoDict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: UIImage(named:  musics[currentMusicIndext].icon)!)
        infoDict[MPMediaItemPropertyPlaybackDuration] = MusicTools.getDuration()
        centerInfo.nowPlayingInfo = infoDict
        
        // 3.让应用程序成为第一响应者
        UIApplication.shared.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        // 1.校验远程事件是否有值
        guard let event = event else {
            return
        }
        
        // 2.处理远程事件
        switch event.subtype {
        case .remoteControlPlay, .remoteControlPause:
            PllayOrPauseMusic(PlayOrPauseBtn)
        case .remoteControlNextTrack:
            nextMusic()
        case .remoteControlPreviousTrack:
            previousMusic()
        default:
            print("-----")
        }
    }
}

































