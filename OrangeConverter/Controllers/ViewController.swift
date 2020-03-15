//
//  ViewController.swift
//  OrangeConverter
//
//  Created by Alex Buga on 14/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var currencyDataSource: CurrencyDataSource!
    var currencyViewModel: CurrencyViewModel!
    var currencyService: CurrencyService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        
        let calendar = UIBarButtonItem()
        calendar.image = UIImage(systemName: "calendar")
        navigationItem.leftBarButtonItem = calendar
        let settings = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showSettings))
        settings.image = UIImage(systemName: "gear")
        navigationItem.rightBarButtonItem = settings
        
    }
    
    @IBAction func showSettings() {
        let menu = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        menu.addAction(UIAlertAction(title: "Default Currency", style: .default, handler: { _ in
            let currenciesAlert = UIAlertController(title: "Choose Default Currency", message: nil, preferredStyle: .alert)
            if let currencies = UserDefaults.standard.stringArray(forKey: "currencies") {
                for currency in currencies {
                    currenciesAlert.addAction(UIAlertAction(title: "\(String.flag(forCountryCode: currency)) \(currency)", style: .default, handler: { _ in
                        UserDefaults.standard.set(currency, forKey: "baseCurrency")
                        self.currencyViewModel.fetchLatestCurrencies()
                    }))
                }
                currenciesAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(currenciesAlert, animated: true, completion: nil)
            }
        }))
        menu.addAction(UIAlertAction(title: "Refresh Interval", style: .default, handler: { _ in
            let intervalAlert = UIAlertController(title: "Refresh Interval", message: nil, preferredStyle: .alert)
            [3, 5, 15].forEach { interval in
                intervalAlert.addAction(UIAlertAction(title: "\(interval) seconds", style: .default, handler: { _ in
                    UserDefaults.standard.set(interval, forKey: "refreshInterval")
                    self.currencyViewModel.fetchLatestCurrencies()
                }))
            }
            intervalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(intervalAlert, animated: true, completion: nil)
        }))
        menu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(menu, animated: true, completion: nil)
    }
    
    func setupTable() {
        currencyDataSource = CurrencyDataSource()
        currencyDataSource.data.addObserver(self, andNotify: true) { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        tableView.dataSource = currencyDataSource
        
        currencyService = CurrencyService()
        currencyViewModel = CurrencyViewModel(currencyService: currencyService, dataSource: currencyDataSource)
        currencyViewModel.fetchLatestCurrencies()

    }


}
