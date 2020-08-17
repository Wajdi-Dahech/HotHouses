//
//  KeyConstants.swift
//  HotHouses
//
//  Created by Katsu on 7/1/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation

struct Key {


    struct Headers {
        static let Authorization = "Authorization"
        static let ContentType = "Content-Type"
    }
    struct HouseAPI{
        static let apiKey = "98bww4ezuzfePCYFxJEWyszbUXc7dxRx"
    }

    struct ErrorMessage{
        static let listNotFound = "ERROR_LIST_NOT_FOUND"
        static let validationError = "ERROR_VALIDATION"
    }
}
