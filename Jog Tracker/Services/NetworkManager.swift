//
//  NetworkManager.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation

class NetworkManager
{
    
    // MARK: POST /v1/auth/uuidLogin
    
    static func uuidLogin(uuid: String, completionHandler: @escaping (Result<AuthResponse, Error>) -> () )
    {
        
        let requestURL = URL(string: "https://jogtracker.herokuapp.com/api/v1/auth/uuidLogin")
        
        guard let url = requestURL else {
            completionHandler(.failure(NetworkError.wrongURL))
            return
        }
        
        let parameter = "uuid=\(uuid)"
        
        guard let uuidData = parameter.data(using: .utf8) else {
            completionHandler(.failure(NetworkError.failedEncodeToData))
            return
        }
        
        if let uuidDataString = String(data: uuidData, encoding: .utf8) {
            print("UUID Login:\n\(uuidDataString)")
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = uuidData
        
        let session = URLSession.shared
        
        let datatask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    completionHandler(.failure(NetworkError.clientError))
                case 500:
                    completionHandler(.failure(NetworkError.internalServerError))
                default:
                    break
                }
            }
            
            if let data = data {
                if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                    print("UUID Login. JSON Result:\n\(String(describing: dataString))")
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let codingData = try? decoder.decode(AuthResponse.CodingData.self, from: data)
                if let codingData = codingData {
                    completionHandler(.success(codingData.authResponse))
                } else {
                    completionHandler(.failure(NetworkError.failedDecodeFromJSON))
                }
            }
        }
        
        datatask.resume()
    }
    
    // MARK: GET /v1/auth/user
    
    static func getUser(accessToken: String, completionHandler: @escaping (Result<User, Error>) -> () )
    {
        let requestURL = URL(string: "https://jogtracker.herokuapp.com/api/v1/auth/user")
        
        guard let url = requestURL else {
            completionHandler(.failure(NetworkError.wrongURL))
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        let datatask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    completionHandler(.failure(NetworkError.clientError))
                case 500:
                    completionHandler(.failure(NetworkError.internalServerError))
                default:
                    break
                }
            }
            
            if let data = data {
                if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                    print("Get User. JSON Result:\n\(String(describing: dataString))")
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let codingData = try? decoder.decode(User.CodingData.self, from: data)
                if let codingData = codingData {
                    completionHandler(.success(codingData.user))
                } else {
                    completionHandler(.failure(NetworkError.failedDecodeFromJSON))
                }
            }
        }
        
        datatask.resume()
        
    }
    
    
    static func syncUsersAndJogs(accessToken: String, completionHandler: @escaping (Result<Response, Error>) -> () )
    {
        let requestURL = URL(string: "https://jogtracker.herokuapp.com/api/v1/data/sync")
        
        guard let url = requestURL else {
            completionHandler(.failure(NetworkError.wrongURL))
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        let datatask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    completionHandler(.failure(NetworkError.clientError))
                case 500:
                    completionHandler(.failure(NetworkError.internalServerError))
                default:
                    break
                }
            }
            
            if let data = data {
                if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                    print("Sync Users And Jogs. JSON Result:\n\(String(describing: dataString))")
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let codingData = try? decoder.decode(Response.CodingData.self, from: data)
                if let codingData = codingData {
                    completionHandler(.success(codingData.passedResponse))
                } else {
                    completionHandler(.failure(NetworkError.failedDecodeFromJSON))
                }
            }
        }
        
        datatask.resume()
    }
    
}


enum NetworkError: Error {
    case clientError
    case failedEncodeToData
    case wrongURL
    case internalServerError
    case failedDecodeFromJSON
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .internalServerError:
            return NSLocalizedString("Failed to perform network request.\nPlease enter another UUID.", comment: "Internal Server Error")
        case .wrongURL:
            return NSLocalizedString("App have wrong URL.\nPlease report to the developer.", comment: "Wrong URL")
        case .failedDecodeFromJSON:
            return NSLocalizedString("App failed to decode data from the network from JSON.\nPlease report to the developer.", comment: "Failed to decode network answer")
        case .failedEncodeToData:
            return NSLocalizedString("App failed to encode parameter to the data.\nPlease report to the developer", comment: "JSON Encoding Failed")
        case .clientError:
            return NSLocalizedString("The request cannot be fulfilled due to bad syntax.\nPlease report to the developer", comment: "Client Side Error")
        }
    }
}
