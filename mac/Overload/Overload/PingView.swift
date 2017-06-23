//
//  PingView.swift
//  Overload
//
//  Created by Mariano Montori on 6/19/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Cocoa

class PingView: NSView {
    
    @IBOutlet weak var LatencyStatus: NSImageView!
    @IBOutlet weak var PingText: NSTextField!
    @IBOutlet weak var Latency: NSTextField!
    @IBOutlet weak var WindowLatencyStatus: NSImageView!
    @IBOutlet weak var WindowPingText: NSTextField!
    @IBOutlet weak var WindowLatency: NSTextField!
    @IBOutlet weak var AvgLatency: NSTextField!
    @IBOutlet weak var MinLatency: NSTextField!
    @IBOutlet weak var MaxLatency: NSTextField!
    @IBOutlet weak var ToggleButton: NSButton!
    @IBOutlet weak var GameSelector: NSPopUpButton!
    @IBOutlet weak var ServerSelector: NSPopUpButton!

}
