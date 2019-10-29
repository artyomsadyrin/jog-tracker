//
//  Report.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/29/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation

struct Report {
    
    // MARK: Public Properties
    
    let weekInterval: DateInterval
    let jogs: [Jog]
    
    // MARK: Private Properties
    
    private var totalDistance: Double {
        return jogs.map { ( Double($0.distance ?? 0)) }.reduce(0.0, +)
    }
    private var totalTime: Double {
        return jogs.map { ( Double($0.time ?? 0)) }.reduce(0.0, +)
    }
    
    // MARK: Init
    
    init(weekInterval: DateInterval, jogs: [Jog]) {
        self.weekInterval = weekInterval
        self.jogs = jogs
    }
    
    // MARK: Public Methods
    
    func getNumberOfWeek() -> Int? {
        if let dateOfFirstValue = jogs.first?.date {
            return Calendar.autoupdatingCurrent.component(.weekOfYear, from: dateOfFirstValue)
        } else {
            return nil
        }
    }
    
    func getAvgSpeed() -> Double {
        return totalDistance / totalTime
    }
    
    func getAvgTime() -> Double {
        return totalTime / Double(jogs.count)
    }
    
    func getTotalDistance() -> Double {
        return totalDistance
    }
    
}
