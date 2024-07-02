//
//  EndPoint.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import Foundation

//MARK: - protocol Endpoint
public protocol EndPoint {
    var host: String { get }
    var scheme: String { get }
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryParams: [String: String]? { get }
    var pathParams: [String: String]? { get }
}

extension EndPoint {
    var scheme: String {
        return "https"
    }
    var host: String {
        return ""
    }
}

//MARK: - struct EndPointCreator
struct EndPointCreator: EndPoint {
    //MARK: - Properties
    var pathParams: [String : String]?
    
    var path: String
    
    var queryParams: [String: String]?
    
    var method: String
    
    var headers: [String : String]? {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
    }
    
    var body: Data?
    
    private let accessToken: String
    
    //MARK: - Intializer
    init(
        pathParams: [String : String]? = nil,
        path: String,
        queryParams: [String : String]? = nil,
        method: String,
        body: Data? = nil,
        accessToken: String
    ) {
        self.pathParams = pathParams
        self.path = path
        self.queryParams = queryParams
        self.method = method
        self.body = body
        self.accessToken = accessToken
    }
}
