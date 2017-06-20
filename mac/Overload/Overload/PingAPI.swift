//
//  PingAPI.swift
//  
//
//  Created by Mariano Montori on 6/20/17.
//
//

import Foundation
import PlainPing

class PingAPI{
    
    func fetchPing(_ query: String) -> String{
        var latencyValue: String = "";
        PlainPing.ping(query, withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                print("latency: \(latency)")
                latencyValue = String(format: "%.2fms", latency)
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
                latencyValue = "error"
            }
        })
        return latencyValue;
    }
}
