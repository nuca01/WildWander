//
//  ListsTableViewModel.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation
import NetworkingService

class ListsTableViewModel {
    private var savedLists: [SavedList] = []
    private var token: String? {
        KeychainHelper.retrieveToken(forKey: "authorizationToken")
    }
    
    private lazy var endPointCreator = EndPointCreator(path: "/api/trail/GetSavedLists", method: "GET", accessToken: token ?? "")
    
    var listsCount: Int {
        savedLists.count
    }
    
    var listDidChange: (() -> Void)?
    
    func listOf(index: Int) -> SavedList {
        savedLists[index]
    }
    
    func getSavedLists() {
        endPointCreator.path = "/api/trail/GetSavedLists"
        endPointCreator.method = "GET"
        endPointCreator.changeAccessToken(accessToken: token)
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<AllSavedList, NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseModel):
                self.savedLists = responseModel.items ?? []
                self.listDidChange?()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func deleteList(index: Int) {
        let id = savedLists[index].id
        
        savedLists.remove(at: index)
        
        endPointCreator.path = "/api/trail/DeleteList/\(id)"
        endPointCreator.method = "POST"
        endPointCreator.changeAccessToken(accessToken: token)
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Bool, NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(_): 
                self.listDidChange?()
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode:
                    message = "decode error has occured"
                case .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                case .noInternetConnection:
                    message = "it seems like you are not connected to internet"
                }
                print(message)
            }
        }
    }
    
    func generateURL(from string: String) -> URL? {
        return URL(string: string)
    }
}
