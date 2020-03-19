//
//  CurrencyViewModel.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation


class CurrencyViewModel: ErrorHandling {
    var handleError: ((Error?) -> Void)?
    
    private weak var currencyService: CurrencyService?
    private weak var dataSource: CurrencyDataSource?
    private var timer: Timer?
    
    init(currencyService: CurrencyService, dataSource: CurrencyDataSource) {
        self.currencyService = currencyService
        self.dataSource = dataSource
    }
    
    public func fetchLatestCurrencies() {
        guard let currencyService = currencyService else {return}

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: CurrencyService.refreshInterval, repeats: true) { (timer) in
            currencyService.fetchLatestCurrencies(completion: { date, rates, error in
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.handleError?(error)
                        return
                    }
                    self.dataSource?.date = String.niceDate(fromTimeStamp: date)
                    self.dataSource?.data.value = rates
                }
            })
        }
        timer?.fire()
    }
    
    public func stopTimer() {
        timer?.invalidate()
    }
    
    deinit {
        stopTimer()
    }
}
