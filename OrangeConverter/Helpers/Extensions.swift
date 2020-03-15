//
//  Extensions.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation

extension String {
    static func flag(forCountryCode code: String) -> String {
        return code
            .dropLast()
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    static func niceDate(fromTimeStamp stamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        let date = formatter.date(from: stamp)
        formatter.dateStyle = .medium
        return date != nil ? formatter.string(from: date!) : "Couldn't parse date"
    }
}
