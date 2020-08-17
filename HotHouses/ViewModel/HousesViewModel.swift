//
//  HousesViewModel.swift
//  HotHouses
//
//  Created by Katsu on 7/3/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation


class HousesViewModel {
    
    
    fileprivate let service = HouseDataService()
    var houses = [House]()
    var message: String?
    var filteredHouses: [House] = []
    // Request Fetch Houses from service
    func fetchHouses(completion: @escaping ((ViewModelState) -> Void)) {
        service.requestFetchHouses { (houses, error) in
            if let error = error {
                self.message = error.localizedDescription
                completion(.failure)
                return
            }
            self.houses = houses
            completion(.success)
        }
    }
    
    
    // Filter Serachbar text
    func filterContentForSearchText(_ searchText: String) {
        
        
        filteredHouses = houses.filter { (house: House ) -> Bool in
            
            let address = house.zip! + " " + house.city!
            let addressInversed = house.city! + " " + house.zip!
            return  address.lowercased().contains(searchText.lowercased()) || addressInversed.lowercased().contains(searchText.lowercased())
        }
        
        
        
    }
    
}
