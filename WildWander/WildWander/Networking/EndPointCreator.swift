//
//  EndPoint.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import Foundation
import NetworkingService

struct EndPointCreator: EndPoint {
    //MARK: - Properties
    var pathParams: [String : String]?
    
    var path: String
    
    var queryItems: [URLQueryItem]?
    
    var method: String
    
    var headers: [String : String]? {
        [
            "Content-Type": "application/json"
        ]
    }
    
    var body: Data?
    
    var host: String
    
    private let accessToken: String?
    
    //MARK: - Intializer
    init(
        host: String = "hikingapp20240711084758.azurewebsites.net",
        pathParams: [String : String]? = nil,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        method: String,
        body: Data? = nil,
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
}
