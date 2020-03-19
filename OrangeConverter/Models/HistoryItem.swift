//
//  HistoryItem.swift
//  OrangeConverter
//
//  Created by Alex Buga on 16/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation

class HistoryItem {
    var currencyCode: String
    var history: [String: CurrencyRate]
    
    init?(currencyCode: String, history: [String: CurrencyRate]? = nil) {
        
        for char in currencyCode {
            if char.isNumber || !char.isUppercase {
                return nil
            }
        }
        
        if currencyCode.count == 3 {
            self.currencyCode = currencyCode
            self.history = history == nil ? [String: CurrencyRate]() : history!
        } else {
            return nil
        }
    }
    
    func add(currencyRate: CurrencyRate, forDate date: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        if let _ = formatter.date(from: date), currencyRate.currencyCode == self.currencyCode {
            history[date] = currencyRate
            return true
        }
        else {
            return false
        }
    }
    
}
