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
    
    var counter:Int = 0
    var timer = Timer()
    var isPinging = false
    var statsBucket:[Double] = []
    var names:[String] = ["League", "Overwatch"]
    var games:[String:[String:String]] = [:]
    
    func startPing() {
        let interval = Double(self.pingView.IntervalSelector.titleOfSelectedItem!)!
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: (#selector(ping)), userInfo: nil, repeats: true)
    }
    
    func ping(){
        let ip = games[self.pingView.GameSelector.titleOfSelectedItem!]![self.pingView.ServerSelector.titleOfSelectedItem!]!
        PlainPing.ping(ip, withTimeout: 0.8, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                self.handlePingView(latency: latency)
            }
            if error != nil {
                self.handlePingError()
            }
        })
    }
    
    func toggleEnabled(value: Bool){
        self.pingView.GameSelector.isEnabled = value;
        self.pingView.ServerSelector.isEnabled = value;
        self.pingView.IntervalSelector.isEnabled = value;
        self.pingView.ClearButton.isEnabled = value;
    }
    
    func togglePinging(){
        if(!isPinging){
            isPinging = true;
            togglePingMenuItem.title = "Stop"
            self.pingView.ToggleButton.title = "Stop"
            toggleEnabled(value: false)
            startPing()
        }
        else{
            isPinging = false;
            togglePingMenuItem.title = "Start"
            self.pingView.ToggleButton.title = "Start"
            toggleEnabled(value: true)
            counter = 0
            calculateStats()
            timer.invalidate()
            handlePingDefault()
        }
    }
    
    func handlePingView(latency: Double){
        statsBucket.append(latency)
        counter += 1
        self.pingView.PingCount.stringValue = String(counter)
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
    
    func changeStats(latency: Double, text: NSTextField, imageView: NSImageView){
        text.stringValue = String(format: "%.2fms", latency)
        if 0 < latency && latency < 100 {
            imageView.image = green
        }
        else if 100 <= latency && latency < 250 {
            imageView.image = yellow
        }
        else if 250 <= latency {
            imageView.image = red
        }
    }
    
    func calculateStats(){
        if !statsBucket.isEmpty {
            let avgLatency = (statsBucket.reduce(0,+)/Double(statsBucket.count))
            let minLatency = statsBucket.min()!
            let maxLatency = statsBucket.max()!
            changeStats(latency: avgLatency, text: self.pingView.AvgLatency, imageView: self.pingView.AvgImage)
            changeStats(latency: minLatency, text: self.pingView.MinLatency, imageView: self.pingView.MinImage)
            changeStats(latency: maxLatency, text: self.pingView.MaxLatency, imageView: self.pingView.MaxImage)
            statsBucket.removeAll()
        }
    }
    
    func addGames(){
        games["League"] = ["NA" : "104.160.131.3", "EUW" : "104.160.141.3", "EUNE" : "104.160.142.3", "OCE" : "104.160.156.1", "LAN" : "104.160.136.3"]
        games["Overwatch"] = ["US West" : "24.105.30.129", "US Central" : "24.105.62.129", "EU1" : "185.60.114.159", "EU2" : "185.60.112.157", "Korea" : "211.234.110.1", "Taiwan" : "203.66.81.98"]
        for game in names{
            pingView.GameSelector.addItem(withTitle: game)
        }
    }
    
    func addServers(game: String){
        for server in games[game]! {
            pingView.ServerSelector.addItem(withTitle: server.key)
        }
    }
    
    func updateServerSelector(){
        pingView.ServerSelector.removeAllItems()
        switch self.pingView.GameSelector.titleOfSelectedItem! {
            case "League":
                addServers(game: "League")
                self.pingView.ServerSelector.selectItem(withTitle: "NA")
                break
            case "Overwatch":
                addServers(game: "Overwatch")
                self.pingView.ServerSelector.selectItem(withTitle: "US West")
                break
            default:
                break
        }
    }
    
    func clearView(){
        self.pingView.WindowLatency.stringValue = "---"
        self.pingView.WindowLatencyStatus.image = NSImage(named: NSImageNameStatusNone)
        self.pingView.AvgImage.image = black
        self.pingView.MinImage.image = black
        self.pingView.MaxImage.image = black
        self.pingView.AvgLatency.stringValue = "---"
        self.pingView.MinLatency.stringValue = "---"
        self.pingView.MaxLatency.stringValue = "---"
        self.pingView.PingCount.stringValue = "0"
    }
    
    override func awakeFromNib() {
        statusItem.image = black
        statusItem.menu = statusMenu
        clearView()
        addGames()
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
    
    @IBAction func clearClicked(_ sender: NSButton) {
        clearView()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
