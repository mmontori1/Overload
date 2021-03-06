//
//  AppDelegate.swift
//  Overload
//
//  Created by Mariano Montori on 6/19/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var pingWindow: NSWindow!

    func openWindow(){
//        NSApp.activate(ignoringOtherApps: true) (possible setting!)
        pingWindow.level = Int(CGWindowLevelForKey(.maximumWindow))
        let pwc = PingWindowController(window: pingWindow)
        pwc.showWindow(self)
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openWindow(_ sender: Any) {
        openWindow()
    }

}

