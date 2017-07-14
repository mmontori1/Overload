//
//  AppDelegate.swift
//  Overload
//
//  Created by Mariano Montori on 7/13/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    
    @IBOutlet var statusItemMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initStatusItem()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func initStatusItem() {
        let editMenuItem = NSMenuItem(title: "Ping", action: #selector(tryPing), keyEquivalent: "")
        statusItemMenu.addItem(editMenuItem)
        
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem?.image = NSImage(named: "blackSub")
        statusItem?.menu = self.statusItemMenu
    }
    
    func tryPing(){
        PingService.ping(server: "104.160.131.3", completion: { (latency) in
          print(latency ?? "error")
        })
    }
}

