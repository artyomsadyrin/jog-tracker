//
//  User.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation

struct User: Codable
{
    let id: String?
    var email: String?
    var phone: String?
    var role: String?
    var firstName: String?
    var lastName: String?
}

extension User
{
    struct CodingData: Codable {
        struct ResponseContainer: Codable {
            let id: String?
            var email: String?
            var phone: String?
            var role: String?
            var firstName: String?
            var lastName: String?
        }
        let response: ResponseContainer
    }
}

extension User.CodingData
{
    var user: User {
        return User(
            id: response.id,
            email: response.email,
            phone: response.phone,
            role: response.role,
            firstName: response.firstName,
            lastName: response.lastName
        )
    }
}
