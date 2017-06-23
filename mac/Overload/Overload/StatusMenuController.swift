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
    let black = NSImage(named: "blackSub")
    let green = NSImage(named: "greenSub")
    let yellow = NSImage(named: "yellowSub")
    let red = NSImage(named: "redSub")
    
    var timer = Timer()
    var isPinging = false
    var statsBucket:[Double] = []
    
    func startPing() {
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: (#selector(ping)), userInfo: nil, repeats: true)
    }
    
    func ping(){
        PlainPing.ping("104.160.131.1", withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                self.handlePingView(latency: latency)
            }
            if error != nil {
                self.handlePingError()
            }
        })
    }
    
    func togglePinging(){
        if(!isPinging){
            isPinging = true;
            togglePingMenuItem.title = "Stop"
            self.pingView.ToggleButton.title = "Stop"
            startPing()
        }
        else{
            isPinging = false;
            togglePingMenuItem.title = "Start"
            self.pingView.ToggleButton.title = "Start"
            calculateStats()
            timer.invalidate()
            handlePingDefault()
        }
    }
    
    func handlePingView(latency: Double){
        statsBucket.append(latency)
        print(String(format: "%.2fms", latency))
        self.pingView.WindowLatency.stringValue = String(format: "%.2fms", latency)
        if 0 < latency && latency < 100 {
            self.pingView.WindowLatencyStatus.image = NSImage(named: NSImageNameStatusAvailable)
        }
        else if 100 <= latency && latency < 250 {
            self.pingView.WindowLatencyStatus.image = NSImage(named: NSImageNameStatusPartiallyAvailable)
        }
        else if 250 <= latency {
            self.pingView.WindowLatencyStatus.image = NSImage(named: NSImageNameStatusUnavailable)
        }
    }
    
    func handlePingError(){
        self.pingView.WindowLatency.stringValue = "error"
        self.pingView.WindowLatencyStatus.image = NSImage(named: NSImageNameStatusNone)
    }
    
    func handlePingDefault(){
        let delay = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.pingView.WindowLatency.stringValue = "---"
            self.pingView.WindowLatencyStatus.image = NSImage(named: NSImageNameStatusNone)
        }
    }
    
    func calculateStats(){
        if !statsBucket.isEmpty {
            self.pingView.AvgLatency.stringValue = String(format: "%.2fms", (statsBucket.reduce(0,+)/Double(statsBucket.count)))
            self.pingView.MinLatency.stringValue = String(format: "%.2fms", statsBucket.min()!)
            self.pingView.MaxLatency.stringValue = String(format: "%.2fms", statsBucket.max()!)
            statsBucket.removeAll()
        }
    }
    
    override func awakeFromNib() {
        statusItem.image = black
        statusItem.menu = statusMenu
    }
    
    @IBAction func windowToggleClicked(_ sender: NSButton) {
        togglePinging()
    }
    
    @IBAction func toggleClicked(_ sender: NSMenuItem) {
        togglePinging()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
