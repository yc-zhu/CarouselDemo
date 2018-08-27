//
//  TimerWeakTarget.swift
//  CarouselDemo
//
//  Created by zyc on 14/08/2018.
//  Copyright © 2018 zyc. All rights reserved.
//

import UIKit

class TimerWeakTarget: NSObject {
    
    weak var timer: Timer!
    weak var target: AnyObject?
    var seletor: Selector?
    
    class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> Timer{
        let timerTarget = TimerWeakTarget()
        timerTarget.timer = Timer.scheduledTimer(timeInterval: ti, target: timerTarget, selector: #selector(fire(timer:)), userInfo: userInfo, repeats: yesOrNo)
        timerTarget.target = aTarget as AnyObject
        timerTarget.seletor = aSelector
        return timerTarget.timer
    }
    @objc func fire(timer: Timer){
        if self.target != nil{
            _ = self.target?.perform(self.seletor!)
        }else{
            self.timer.invalidate()
        }
        
    }

}
