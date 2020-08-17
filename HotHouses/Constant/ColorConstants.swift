//
//  ColorConstants.swift
//  HotHouses
//
//  Created by Katsu on 7/1/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

struct AppColor {

   
    struct SearchBarColors{
        static let Background = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        static let Hint = UIColor(hex: "#00000033")
        static let Input = UIColor(hex: "#000000CC")
    }

    struct OverAllColors {
        static let Background = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        static let Title = UIColor(hex: "#000000CC")
        static let Description = UIColor(hex: "#00000066")
        static let Details = UIColor(hex: "#00000066")
        

    }
    

}

