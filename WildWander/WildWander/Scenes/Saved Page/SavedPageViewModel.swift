//
//  SavedPageViewModel.swift
//  WildWander
//
//  Created by nuca on 22.07.24.
//

import Foundation
import NetworkingService

class SavedPageViewModel {
    private var token: String? {
        KeychainHelper.retrieveToken(forKey: "authorizationToken")
    }
    
    var isUserLoggedIn: Bool {
        token == nil ? false: true
    }
    
    var onTrailCreated: (() -> Void)?
    
    private var trails: [Trail] = []
    
    var trailsDidChange: ((_: [Trail]) -> Void)?
    
    func createList(createListModel: CreateList) {
        let endPoint = getEndPointCreator(
            path: "/api/Trail/AddList",
            method: "POST",
            body: createListModel,
            queryItems: nil
        )
        
        NetworkingService.shared.sendRequest(endpoint: endPoint) { [weak self] (result: Result<Bool, NetworkError>) in
            switch result {
            case .success(_): 
                self?.onTrailCreated?()
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode: break
                case .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                }
                print(message)
            }
        }
    }
    
    private func configureEndPointCreatorForGet(listId: Int) -> EndPointCreator {
        let queryItems = [
            URLQueryItem(name: "SavedListId", value: "\(listId)")
        ]
        
        return getEndPointCreator(
            path: "/api/trail/gettrails",
            method: "GET",
            body: nil,
            queryItems: queryItems
        )
    }
    
    func getTrails(listId: Int) {
        let endPoint = configureEndPointCreatorForGet(listId: listId)
        
        NetworkingService.shared.sendRequest(endpoint: endPoint) { [weak self] (result: Result<TrailContainer, NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseModel):
                self.trails = responseModel.items ?? []
                self.trailsDidChange?(trails)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func getEndPointCreator(
        path: String,
        method: String,
        body: Encodable?,
        queryItems: [URLQueryItem]?
    ) -> EndPointCreator {
        EndPointCreator(path: path, queryItems: queryItems, method: method, body: body, accessToken: token ?? "")
    }
}
