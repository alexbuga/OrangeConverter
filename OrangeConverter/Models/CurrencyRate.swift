//
//  CurrencyRate.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation

class CurrencyRate: NSObject {
    var currencyCode: String
    var rate: Double
    
    init?(currencyCode: String, rate: Double) {
        for char in currencyCode {
            if char.isNumber || !char.isUppercase {
                return nil
            }
        }
        
        if currencyCode.count == 3 && rate > 0 {
            self.currencyCode = currencyCode
            self.rate = rate
        } else {
            return nil
        }
    }
}
