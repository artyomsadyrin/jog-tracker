//
//  Response.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/25/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation

struct Response: Codable
{
    let jogs: [Jog]
    let users: [User]
}

extension Response
{
    struct CodingData: Codable {
        struct ResponseContainer: Codable {
            struct JogsContainer: Codable {
                let id: Int?
                let userId: String?
                var distance: Double?
                var time: Int?
                var date: Int?
            }
            struct UsersContainer: Codable {
                let id: String?
                var email: String?
                var phone: String?
                var role: String?
                var firstName: String?
                var lastName: String?
            }
            let jogs: [JogsContainer]
            let users: [UsersContainer]
        }
        let response: ResponseContainer
    }
}

extension Response.CodingData
{
    var passedResponse: Response {
        return Response(
            jogs: response.jogs.map {
                Jog(
                    id: $0.id,
                    userId: $0.userId,
                    distance: $0.distance,
                    time: $0.time,
                    date: Date.init(timeIntervalSince1970: TimeInterval($0.date!))
                )},
            users: response.users.map {
                User(
                    id: $0.id,
                    email: $0.email,
                    phone: $0.phone,
                    role: $0.role,
                    firstName: $0.firstName,
                    lastName: $0.lastName
                )}
        )
    }
}
