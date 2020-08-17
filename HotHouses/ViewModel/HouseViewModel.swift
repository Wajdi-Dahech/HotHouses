//
//  HouseViewModel.swift
//  HotHouses
//
//  Created by Katsu on 7/5/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation
//
class HouseViewModel {
    
    var houseId: Int?
    
    fileprivate let service = HouseDataService()
    
    var house: House?
    var message: String?
    
    // Request Fetch House from service
    func fetchHouse(with id: Int, completion: @escaping ((ViewModelState) -> Void)) {
        service.requestFetchHouse(with: id) { (house, error) in
            if let error = error {
                self.message = error.localizedDescription
                completion(.failure)
                return
            }
            self.house = house
            self.houseId = house?.id
            completion(.success)
        }
    }
}
