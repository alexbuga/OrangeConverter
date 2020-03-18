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

        let defaultInterval = UserDefaults.standard.double(forKey: "refreshInterval")
        let interval = defaultInterval == 0 ? 3 : defaultInterval

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
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
