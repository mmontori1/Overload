//
//  StatusMenuController.swift
//  Overload
//
//  Created by Mariano Montori on 6/19/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import Cocoa
import PlainPing

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var pingView: PingView!
    var pingMenuItem: NSMenuItem!
    struct Ping {
        var latency: Float
    }

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var timer = Timer()
    var isPinging = false
    
    func startPing() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.ping)), userInfo: nil, repeats: true)
    }
    
    func ping() {
        PlainPing.ping("104.160.131.1", withTimeout: 2.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                print("latency (ms): \(latency)")
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
        })
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        // icon?.isTemplate = true 
        // best for dark mode
        statusItem.image = icon
        let current = Ping(latency: 5.0)
        statusMenu.item(withTitle: "current")
        pingMenuItem.view = pingView
    }
    
    //change to toggle ping
    @IBAction func startClicked(_ sender: NSMenuItem) {
        if(!isPinging){
            startPing()
            isPinging = true;
        }
        else{
            timer.invalidate()
            isPinging = false;
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
