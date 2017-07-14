//
//  PingService.swift
//  Overload
//
//  Created by Mariano Montori on 7/13/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import PlainPing

struct PingService {
    static func ping(server ip: String, completion: @escaping (Double?) -> Void) {
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
        
    }
    
    static func stopPing(){
        
    }
    
}
