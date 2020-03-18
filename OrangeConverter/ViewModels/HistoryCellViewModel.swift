//
//  HistoryCellViewModel.swift
//  OrangeConverter
//
//  Created by Alex Buga on 16/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class HistoryCellViewModel {
    private var historyItem: HistoryItem!
    
    init(historyItem: HistoryItem) {
        self.historyItem = historyItem
    }
    
    var title: String {
        get {
            return "\(String.flag(forCountryCode: CurrencyService.baseCurrency) + " " + CurrencyService.baseCurrency) ➜ \(String.flag(forCountryCode: historyItem.currencyCode) + " " + historyItem.currencyCode)"
        }
    }
    
    var columnNames: [String] {
        return historyItem.history.keys.sorted()
    }
    
    var values: [Float] {
        get {
            let results = historyItem.history.sorted{$0.key < $1.key}.compactMap {Float($0.value.rate)}
            return results
        }
    }
}

