//
//  HouseDataService.swift
//  HotHouses
//
//  Created by Katsu on 7/3/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation
import Moya

class HouseDataService {
    // add proper header paramaters for API request
    fileprivate let provider = MoyaProvider<HouseService>(endpointClosure: { (target: HouseService) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        switch target {
        default:
            let httpHeaderFields = [
                "Access-Key": Key.HouseAPI.apiKey ,
                "Content-Type": "application/json"
            ]
            return defaultEndpoint.adding(newHTTPHeaderFields: httpHeaderFields)
        }
    })
    // Handle fetch house request reponse ordered by price (cheapest first)
    func requestFetchHouses(completion: @escaping (([House], Error?) -> Void)) {
        provider.request(.fetchHouses) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    var houses = try decoder.decode([House].self, from: response.data)
                    houses = houses.sorted(by: { (item0:House, item1:House) -> Bool in
                        item0.price! < item1.price!
                    })
                    
                    completion(houses, nil)
                } catch (let error) {
                    completion([], error)
                }
            case .failure(let error):
                completion([], error)
            }
        }
    }
    // Handle fetch house request reponse and decoder
    func requestFetchHouse(with id: Int, completion: @escaping ((House?, Error?) -> Void)) {
        provider.request(.fetchHouse(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    let house = try decoder.decode(House.self, from: response.data)
                    completion(house, nil)
                } catch (let error) {
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}

