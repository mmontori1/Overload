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
    
    struct Game{
        var name:String
        var servers:[String: String]
    }
    
    var games:[String:[String: String]] = [:]
    
    var league = Game(name: "League", servers: ["NA" : "104.160.131.3", "EUW" : "104.160.141.3", "EUNE" : "104.160.142.3", "OCE" : "104.160.156.1", "LAN" : "104.160.136.3"])
    var overwatch = Game(name: "Overwatch", servers: ["US West" : "24.105.30.129", "US Central" : "24.105.62.129", "EU1" : "185.60.114.159", "EU2" : "185.60.112.157", "Korea" : "211.234.110.1", "Taiwan" : "203.66.81.98"])
    
    func startPing() {
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: (#selector(ping)), userInfo: nil, repeats: true)
    }
    
    func ping(){
        print(games[self.pingView.GameSelector.titleOfSelectedItem!]![self.pingView.ServerSelector.titleOfSelectedItem!]!)
        PlainPing.ping(games[self.pingView.GameSelector.titleOfSelectedItem!]![self.pingView.ServerSelector.titleOfSelectedItem!]!, withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
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
    
    func updateServerSelector(){
        pingView.ServerSelector.removeAllItems()
        for server in games[self.pingView.GameSelector.titleOfSelectedItem!]!.keys {
            pingView.ServerSelector.addItem(withTitle: server)
        }
        switch self.pingView.GameSelector.titleOfSelectedItem! {
            case league.name:
                self.pingView.ServerSelector.selectItem(withTitle: "NA")
                break
            case overwatch.name:
                self.pingView.ServerSelector.selectItem(withTitle: "US Central")
                break
            default:
                break
        }
    }
    
    override func awakeFromNib() {
        statusItem.image = black
        statusItem.menu = statusMenu
        games[league.name] = league.servers
        games[overwatch.name] = overwatch.servers
        pingView.GameSelector.addItem(withTitle: league.name)
        pingView.GameSelector.addItem(withTitle: overwatch.name)
        updateServerSelector()
    }
    
    @IBAction func changeGame(_ sender: Any) {
        updateServerSelector()
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
