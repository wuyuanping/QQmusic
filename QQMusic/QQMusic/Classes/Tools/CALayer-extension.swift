//
//  CALayer-extension.swift
//  QQMusic
//
//  Created by 吴园平 on 28/11/2016.
//  Copyright © 2016 WuYuanPing. All rights reserved.
//

import UIKit

extension CALayer {
    func pauseAnim() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    func resumeAnim() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let currentTime = convertTime(CACurrentMediaTime(), from: nil)
        beginTime = currentTime - pausedTime
    }
}
