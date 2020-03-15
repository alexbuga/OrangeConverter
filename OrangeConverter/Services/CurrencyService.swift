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
    
    let latestCurrencies = "https://api.exchangeratesapi.io/latest"
    
    func fetchLatestCurrencies(completion: @escaping CompletionBlock<(String, [CurrencyRate])>) {
        AF.cancelAllRequests()
        
        let parameters = ["base": UserDefaults.standard.string(forKey: "baseCurrency") ?? "EUR"]
        
        AF.request(latestCurrencies, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success:
                guard
                    let json = response.value as? [String: Any],
                    let dateString = json["date"] as? String,
                    let ratesDict = json["rates"] as? [String: Double]
                else {
                    completion(("", []))
                    return
                }
                
                let rates = ratesDict
                    .compactMap {CurrencyRate(currency: $0.key, rate: $0.value)}
                    .sorted { $0.currency < $1.currency }

                //Set API list of currencies in UserDefaults for further reference in Settings.
                UserDefaults.standard.set(ratesDict.keys.sorted(), forKey: "currencies")
                
                completion((dateString, rates))
                
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
