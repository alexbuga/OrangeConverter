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
    
    init(currencyCode: String, history: [String: CurrencyRate]) {
        self.currencyCode = currencyCode
        self.history = history
    }
}
