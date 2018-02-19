//
//  PingService.swift
//  Overload
//
//  Created by Mariano Montori on 7/13/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import Cocoa
import PlainPing

struct PingService {
    
    
    func ping(server ip: String, completion: @escaping (Double?) -> Void) {
        return PlainPing.ping(ip, withTimeout: 1, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                return completion(latency)
            }
            if error != nil {
                completion(nil)
            }
        })
    }
    
    static func startPing(){
        let interval = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            ping(server: "104.160.131.3", completion: { (latency) in
                print(latency ?? "error")
            }) 
        }
        /*
        var _ : Timer? = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: ping(server: "104.160.131.3", completion: { (latency) in
                print(latency ?? "error")
            })
        )
        */
    }
    
    static func stopPing(){
        
    }
    
}
