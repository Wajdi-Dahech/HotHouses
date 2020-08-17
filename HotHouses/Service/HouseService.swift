//
//  HouseService.swift
//  HotHouses
//
//  Created by Katsu on 7/3/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation
import Moya

enum HouseService {
    
    case fetchHouses
    
    case fetchHouse(id: Int)
    
}
// Setting up methods for API CALLS
extension HouseService: TargetType {
    
    var baseURL: URL {
        let baseUrl = APPURL.BaseURL
        guard let url = URL(string: baseUrl) else {
            fatalError("URL cannot be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchHouses:
            return "/house"
        case .fetchHouse(let id):
            return "/house/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchHouses:
            return .get
        case .fetchHouse(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

