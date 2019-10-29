//
//  AuthResponse.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation

struct AuthResponse: Codable
{
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let scope: String?
    let createdAt: Int?
}

extension AuthResponse
{
    struct CodingData: Codable {
        struct ResponseContainer: Codable {
            let accessToken: String?
            let tokenType: String?
            let expiresIn: Int?
            let scope: String?
            let createdAt: Int?
        }
        let response: ResponseContainer
        let timestamp: Int
    }
}

extension AuthResponse.CodingData
{
    var authResponse: AuthResponse {
        return AuthResponse(accessToken: response.accessToken, tokenType: response.tokenType, expiresIn: response.expiresIn, scope: response.scope, createdAt: response.createdAt)
    }
}
