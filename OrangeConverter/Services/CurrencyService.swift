//
//  CurrencyService.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation
import Alamofire


class CurrencyService {
    
    struct ServiceError : LocalizedError {
        var localizedDescription: String {return message}
        private var message : String
        init(_ description: String? = nil) {
            message = description ?? "An unexpected error occurred."
        }
    }
    
    //MARK: Variables
    ///Current / Default currency used by the service as a reference
    static var baseCurrency: String {
        get {
            return UserDefaults.standard.string(forKey: "baseCurrency") ?? "EUR"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "baseCurrency")
        }
    }
    
    ///Caches the list of currencies provided by the API so we can use them in the Change Currency dialog (or other parts of the app)
    static var currencies: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "currencies") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currencies")
        }
    }
    
    //MARK: API URL
    let latestCurrenciesURL = "https://api.exchangeratesapi.io/latest"
    let historyURL = "https://api.exchangeratesapi.io/history"
    
    //MARK: Strings
    let genericError = "An unexpected error occurred."
    
    ///Fetches the latest currencies from the API
    ///- Parameter completion: A completion block that gets called with the date and list of currency rates provided by the API
    func fetchLatestCurrencies(completion: @escaping CompletionBlock<(String, [CurrencyRate], Error?)>) {
        AF.cancelAllRequests()
        
        let parameters = ["base": CurrencyService.baseCurrency]
        
        AF.request(latestCurrenciesURL, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success:
                guard
                    let json = response.value as? [String: Any],
                    let dateString = json["date"] as? String,
                    let ratesDict = json["rates"] as? [String: Double]
                else {
                    completion(("", [], ServiceError()))
                    return
                }
                
                let rates = ratesDict
                    .compactMap {CurrencyRate(currency: $0.key, rate: $0.value)}
                    .sorted { $0.currency < $1.currency }

                //Set API list of currencies in UserDefaults for further reference in Settings.
                CurrencyService.currencies = ratesDict.keys.sorted()
                
                completion((dateString, rates, nil))
                
            case let .failure(error):
                completion(("", [], ServiceError(error.localizedDescription)))
            }
        }
    }
    
    ///Fetches the historical rates for the last 10 days for the provided currencies
    ///- Parameter currencies: An array of currencies
    ///- Parameter completion: A completion block that gets called with the history items
    func fetchHistory(forCurrencies currencies: [String], completion: @escaping CompletionBlock<([HistoryItem], Error?)>) {
        let parameters = [
            "base": CurrencyService.baseCurrency,
            "start_at": Date(timeIntervalSinceNow: -10 * 24 * 3600).apiFormat(),
            "end_at": Date().apiFormat(),
            "symbols": currencies.joined(separator: ",")
        ]
        
        AF.request(historyURL, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success:
                guard
                    let json = response.value as? [String: Any],
                    let daysDict = json["rates"] as? [String: [String: Double]]
                else {
                    completion(([], ServiceError()))
                    return
                }
                
                var results = [HistoryItem]()
                
                //Create a history item for each day. If only time travel would be possible 🤔
                currencies.forEach { currency in
                    results.append(HistoryItem(currencyCode: currency, history: [:]))
                }
                
                for day in daysDict {
                    for item in day.value {
                        //Get each history item for each day and put the mofo in its right place 😆
                        let historyItem = results.first {$0.currencyCode == item.key}!
                        historyItem.history[day.key] = CurrencyRate(currency: item.key, rate: item.value)
                    }
                }
                completion((results, nil))
                
            case let .failure(error):
                completion(([], error))
            }
        }
    }
}
