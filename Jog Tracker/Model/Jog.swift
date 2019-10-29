//
//  Jog.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/25/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation

struct Jog: Codable, Dateable {
    let identifier: Int?
    let userId: String?
    var distance: Double?
    var time: Int?
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userId = "user_id"
        case distance = "distance"
        case time = "time"
        case date = "date"
    }
}
