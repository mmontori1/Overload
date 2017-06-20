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
    @IBOutlet weak var togglePingMenuItem: NSMenuItem!
    
    var pingMenuItem: NSMenuItem!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var timer = Timer()
    var isPinging = false
    
    func startPing() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.ping)), userInfo: nil, repeats: true)
    }
    
    func ping() {
        PlainPing.ping("104.160.131.1", withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                print("wow")
                self.pingView.Latency.stringValue = String(format: "%.2fms", latency)
//                   self.statusItem.title = "Ping: " + String(format: "%.2fms", latency)
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
        })
        
    }
    
    func togglePinging(){
        if(!isPinging){
            isPinging = true;
            togglePingMenuItem.title = "Stop"
            startPing()
        }
        else{
            isPinging = false;
            togglePingMenuItem.title = "Start"
            self.pingView.Latency.stringValue = "---"
//            self.statusItem.title = "Ping: ---"
            timer.invalidate()
        }
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        // icon?.isTemplate = true
        // best for dark mode
        pingMenuItem = statusMenu.item(withTitle: "Item")
        pingView.Latency.stringValue = "---"
        pingMenuItem.view = pingView
        statusItem.image = icon
//        statusItem.title = "Ping: ---"
        statusItem.menu = statusMenu
    }
    
    @IBAction func startClicked(_ sender: NSMenuItem) {
        togglePinging()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
