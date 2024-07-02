//
//  NetworkService.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import Foundation

//MARK: - enum NetworkError
enum NetworkError: Error {
    case invalidURL
    case unexpectedStatusCode(String = "The status code returned was unexpected.")
    case unknown(String = "An unknown error occurred.")
    case decode
}

//MARK: - class NetworkService
final class NetworkService {
    public static var shared = NetworkService()
    
    private init(){}
    
    func sendRequest<T: Decodable>(endpoint: EndPoint, resultHandler: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let urlRequest = createRequest(endPoint: endpoint) else {
            return
        }
        
        let urlTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                resultHandler(.failure(.invalidURL))
                return
            }
            guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                resultHandler(.failure(.unexpectedStatusCode(response?.description ?? "An unknown error occurred.")))
                return
            }
            guard let data = data else {
                resultHandler(.failure(.unknown()))
                return
            }
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                resultHandler(.failure(.decode))
                return
            }
            resultHandler(.success(decodedResponse))
        }
        urlTask.resume()
    }
    
    //MARK: - private helper method
    private func createRequest(endPoint: EndPoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endPoint.scheme
        urlComponents.host = endPoint.host
        urlComponents.path = endPoint.path
        urlComponents.queryItems = endPoint.queryItems
        guard let url = urlComponents.url else {
            return nil
        }
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method
        request.allHTTPHeaderFields = endPoint.headers
        if let body = endPoint.body {
            request.httpBody = try? encoder.encode(body)
        }
        return request
    }
}
