//
//  EndPoint.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import Foundation
import NetworkingService

class EndPointCreator: EndPoint {
    //MARK: - Properties
    var pathParams: [String : String]?
    
    var path: String
    
    var queryItems: [URLQueryItem]?
    
    var method: String
    
    var headers: [String : String]? {
        if let accessToken, !accessToken.isEmpty {
            [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        } else {
            [
                "Content-Type": "application/json"
            ]
        }
    }
    
    var body: Encodable?
    
    var host: String
    
    private var accessToken: String?
    
    //MARK: - Intializer
    init(
        host: String = "hikingapp20240711084758.azurewebsites.net",
        pathParams: [String : String]? = nil,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        method: String,
        body: Encodable? = nil,
        accessToken: String
    ) {
        self.host = host
        self.pathParams = pathParams
        self.path = path
        self.queryItems = queryItems
        self.method = method
        self.body = body
        self.accessToken = accessToken
    }
    
    //MARK: - Methods
    func changeAccessToken(accessToken: String?) {
        self.accessToken = accessToken
    }
}
