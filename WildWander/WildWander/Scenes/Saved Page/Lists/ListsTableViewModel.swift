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
    private var endPointCreator = {
        let token = KeychainHelper.retrieveToken(forKey: "authorizationToken")
        
        let endPointCreator = EndPointCreator(path: "/api/trail/GetSavedLists", method: "GET", accessToken: token ?? "")
        
        return endPointCreator
    }()
    
    var listsCount: Int {
        savedLists.count
    }
    
    var listDidChange: (() -> Void)?
    
    func listOf(index: Int) -> SavedList {
        savedLists[index]
    }
    
    func getSavedLists() {
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
}
