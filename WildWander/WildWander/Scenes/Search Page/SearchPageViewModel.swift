//
//  SearchPageViewModel.swift
//  WildWander
//
//  Created by nuca on 16.07.24.
//

import Foundation
import NetworkingService

class SearchPageViewModel {
    //MARK: - Properties
    private var locations: [Location] = []
    private var searchQuery: String = ""
    private let accessToken = "6691949750cf3596845752wgub09b0a"
    
    private var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "q", value: searchQuery),
            URLQueryItem(name: "api_key", value: accessToken)
        ]
    }
    
    private var endPointCreator: EndPointCreator {
        EndPointCreator(
            host: "geocode.maps.co",
            pathParams: ["q": searchQuery, "api_key": accessToken],
            path: "/search",
            queryItems: queryItems,
            method: "GET",
            accessToken: accessToken
        )
    }
    
    var locationsCount: Int {
        locations.count
    }
    
    var dataDidChange: () -> Void
    
    //MARK: - Initializer
    init(didGetData: @escaping () -> Void) {
        self.dataDidChange = didGetData
    }
    
    //MARK: - Methods
    func locationFor(index: Int) -> Location {
        locations[index]
    }
  
    func search(with searchQuery: String) {
        self.searchQuery = searchQuery
        getLocations()
    }
    
    func clearData() {
        locations = []
        dataDidChange()
    }
    
    private func getLocations() {
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<[Location], NetworkError>) in
            guard let self else { return }
            switch result {
            case .success(let responseModel):
                self.locations = responseModel
                dataDidChange()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
