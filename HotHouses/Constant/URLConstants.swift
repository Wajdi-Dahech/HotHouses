//
//  URLConstants.swift
//  HotHouses
//
//  Created by Katsu on 7/1/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import Foundation

  struct APPURL {

    private struct Domains {
        static let Dev = "https://intern.docker-dev.d-tt.nl"
    }

    private  struct Routes {
        static let Api = "/api"
    }

    private  static let Domain = Domains.Dev
    private  static let Route = Routes.Api
    
    static var BaseURL: String {
        return Domain + Route
    }
    
    static var DomainURL: String {
        return Domain
    }
}
