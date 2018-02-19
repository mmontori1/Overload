//
//  TimerInvocation.swift
//  
//
//  Created by Mariano Montori on 7/14/17.
//
//

import Foundation
import Cocoa

final class TimerInvocation: NSObject {
    
    var callback: () -> ()
    
    init(callback: @escaping () -> ()) {
        self.callback = callback
    }
    
    func invoke() {
        callback()
    }
}

extension Timer {
    
    static func scheduleTimer(timeInterval: TimeInterval, repeats: Bool, invocation: TimerInvocation) {
        
        Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: invocation,
            selector: #selector(TimerInvocation.invoke),
            userInfo: nil,
            repeats: repeats)
    }
}
