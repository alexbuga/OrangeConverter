//
//  HistoryViewModel.swift
//  OrangeConverter
//
//  Created by Alex Buga on 16/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation

class HistoryViewModel: ErrorHandling {
    
    var handleError: ((Error?) -> Void)?
    
    private weak var currencyService: CurrencyService?
    private weak var dataSource: HistoryDataSource?
    
    init(service: CurrencyService, dataSource: HistoryDataSource) {
        self.currencyService = service
        self.dataSource = dataSource
    }
    
    func fetchHistory(forCurrencies currencies: [String]) {
        guard let currencyService = currencyService else {return}
        currencyService.fetchHistory(forCurrencies: currencies, completion: {items, error  in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.handleError?(error)
                    return
                }
                self.dataSource?.data.value = items
            }
        })
    }
}
