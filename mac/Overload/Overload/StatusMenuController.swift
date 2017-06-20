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
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ping)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func ping() {
        PlainPing.ping("104.160.131.1", withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                print(String(format: "%.2fms", latency))
                self.handlePingView(latency: latency)
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
                self.handlePingError()
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
            timer.invalidate()
            handlePingDefault()
        }
    }
    
    func handlePingView(latency: Double){
        self.pingView.Latency.stringValue = String(format: "%.2fms", latency)
        if 0 < latency && latency < 100 {
            self.pingView.LatencyStatus.image = NSImage(named: NSImageNameStatusAvailable)
        }
        else if 100 <= latency && latency < 250 {
            self.pingView.LatencyStatus.image = NSImage(named: NSImageNameStatusPartiallyAvailable)
        }
        else if 250 <= latency {
            self.pingView.LatencyStatus.image = NSImage(named: NSImageNameStatusUnavailable)
        }
    }
    
    func handlePingError(){
        self.pingView.Latency.stringValue = "error"
        self.pingView.LatencyStatus.image = NSImage(named: NSImageNameStatusNone)
    }
    
    func handlePingDefault(){
        let delay = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.pingView.Latency.stringValue = "---"
            self.pingView.LatencyStatus.image = NSImage(named: NSImageNameStatusNone)
        }
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        // icon?.isTemplate = true
        // best for dark mode
        pingMenuItem = statusMenu.item(withTitle: "Item")
        pingView.Latency.stringValue = "---"
        pingView.LatencyStatus.image = NSImage(named: NSImageNameStatusNone)
        pingMenuItem.view = pingView
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @IBAction func toggleClicked(_ sender: Any) {
        togglePinging()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
