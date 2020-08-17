//
//  House.swift
//  HotHouses
//
//  Created by Katsu on 7/3/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation

// MARK: - House
struct House: Codable {
    let id: Int?
    let image: String?
    let price: Int?
    let bedrooms: Int?
    let bathrooms: Int?
    let size: Int?
    let description: String?
    let zip: String?
    let city: String?
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
        case price = "price"
        case bedrooms = "bedrooms"
        case bathrooms = "bathrooms"
        case size = "size"
        case description = "description"
        case zip = "zip"
        case city = "city"
        case latitude = "latitude"
        case longitude = "longitude"
        
    }
}
