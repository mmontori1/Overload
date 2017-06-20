//
//  PingView.swift
//  Overload
//
//  Created by Mariano Montori on 6/19/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Cocoa

class PingView: NSView {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var PingText: NSTextField!
    @IBOutlet weak var Latency: NSTextField!
    
    func update(_ value: String){
        DispatchQueue.main.async {
            self.Latency.stringValue = value
        }
    }
    
}
