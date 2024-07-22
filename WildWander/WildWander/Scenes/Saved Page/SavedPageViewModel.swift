//
//  SavedPageViewModel.swift
//  WildWander
//
//  Created by nuca on 22.07.24.
//

import Foundation
import NetworkingService

class SavedPageViewModel {
    private lazy var token = KeychainHelper.retrieveToken(forKey: "authorizationToken")
    
    private lazy var endPointCreator = EndPointCreator(path: "/api/Trail/AddList", method: "POST", accessToken: token ?? "")
    
    var onTrailCreated: (() -> Void)?
    
    private var trails: [Trail] = []
    
    var trailsDidChange: ((_: [Trail]) -> Void)?
    
    func createList(createListModel: CreateList) {
        endPointCreator.path = "/api/Trail/AddList"
        endPointCreator.method = "POST"
        endPointCreator.body = createListModel
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Bool, NetworkError>) in
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
    
    private func configureEndPointCreatorForGet(listId: Int) {
        let queryItems = [
            URLQueryItem(name: "SavedListId", value: "\(listId)")
        ]
        endPointCreator.path = "/api/trail/gettrails"
        endPointCreator.method = "GET"
        endPointCreator.body = nil
        endPointCreator.queryItems = queryItems
    }
    
    func getTrails(listId: Int) {
        configureEndPointCreatorForGet(listId: listId)
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<TrailContainer, NetworkError>) in
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
}
