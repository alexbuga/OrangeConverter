//
//  CurrencyCellViewModel.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class CurrencyCellViewModel {
    
    private var rate: CurrencyRate!
    var currencyCode: String {
        get {
            return "\(String.flag(forCountryCode: rate.currency)) \(rate.currency)"
        }
    }
    var currencyRate: String {
        get {
            let formatter = NumberFormatter()
            formatter.currencySymbol = ""
            formatter.numberStyle = .currency
            return formatter.string(from: NSNumber(value: rate.rate)) ?? "0"
        }
    }
    
    init(rate: CurrencyRate) {
        self.rate = rate
    }
}
