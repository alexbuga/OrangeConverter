//
//  ViewController.swift
//  OrangeConverter
//
//  Created by Alex Buga on 14/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class CurrenciesViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tableView: UITableView!
    var gradient: CAGradientLayer!

    var currencyDataSource: CurrencyDataSource!
    var currencyViewModel: CurrencyViewModel!
    var currencyService: CurrencyService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.delegate = self
        setupTableView()
        updateHeaderText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        currencyViewModel.fetchLatestCurrencies()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currencyViewModel.stopTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = tableView.superview?.bounds ?? .zero
    }
    
    func updateHeaderText() {
        let titleValue = "\(CurrencyService.baseCurrency) Currencies"
        title = titleValue
        headerView.titleLabel.text = titleValue
        headerView.subtitleLabel.text = currencyDataSource.date
    }
    
    @IBAction func showHistory() {
        performSegue(withIdentifier: "showHistory", sender: nil)
    }
    
    func setupTableView() {
        currencyDataSource = CurrencyDataSource()
        currencyDataSource.data.addObserver(self, andNotify: true) { [weak self] _ in
            self?.updateHeaderText()
            self?.tableView.reloadData()
        }
        
        tableView.register(UINib(nibName: "DateHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UINib(nibName: "CurrencyCell", bundle: Bundle.main), forCellReuseIdentifier: "row")
        tableView.dataSource = currencyDataSource
        tableView.delegate = currencyDataSource
        
        currencyService = CurrencyService()
        currencyViewModel = CurrencyViewModel(currencyService: currencyService, dataSource: currencyDataSource)
        currencyViewModel.handleError = { error in
            self.showAlert(title: "Oops", message: error?.localizedDescription)
        }
        
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowRadius = 10
        tableView.layer.shadowOffset.height = 2
        
        //Top Mask
        let mask = UIView(frame: tableView.superview?.bounds ?? .zero)
        mask.isUserInteractionEnabled = false
        gradient = CAGradientLayer()
        gradient.frame = mask.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 0.02]
        mask.layer.addSublayer(gradient)
        tableView.superview?.mask = mask
    }
    
    deinit {
        let _ = currencyDataSource.data.removeObserver(self)
    }

}

//MARK: Header Delegate
extension CurrenciesViewController: HeaderViewDelegate {
    
    func headerView(didTapButton type: HeaderView.ButtonType) {
        switch type {
        case .history:
            showHistory()
        case .settings:
            showSettings()
        }
    }
}

//MARK: Settings section
extension CurrenciesViewController {
    func showChangeDefaultCurrency() {
        let currenciesAlert = UIAlertController(title: "Choose Default Currency", message: "Current currency: \(CurrencyService.baseCurrency)", preferredStyle: .actionSheet)
        for currency in CurrencyService.currencies {
            let action = UIAlertAction(title: "\(String.flag(forCountryCode: currency)) \(currency)", style: .default, handler: { _ in
                CurrencyService.baseCurrency = currency
                self.updateHeaderText()
                self.currencyViewModel.fetchLatestCurrencies()
            })
            action.setValue(CurrencyService.baseCurrency == currency, forKey: "checked")
            currenciesAlert.addAction(action)
        }
        currenciesAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(currenciesAlert, animated: true, completion: nil)
    }
    
    func showChangeInterval() {
        let intervalAlert = UIAlertController(title: "Refresh Interval", message: nil, preferredStyle: .actionSheet)
        intervalAlert.view.tintColor = UIColor(named: "DarkPurple")
        
        [3.0, 5.0, 15.0].forEach { interval in
            let action = UIAlertAction(title: "\(Int(interval)) seconds", style: .default, handler: { _ in
                UserDefaults.standard.set(interval, forKey: "refreshInterval")
                self.currencyViewModel.fetchLatestCurrencies()
            })
            action.setValue(CurrencyService.refreshInterval == interval, forKey: "checked")
            intervalAlert.addAction(action)
        }
        intervalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(intervalAlert, animated: true, completion: nil)
    }
    
    @IBAction func showSettings() {
        let menu = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor(named: "DarkPurple")
        
        let changeCurrencyAction = UIAlertAction(title: "Change Default Currency", style: .default, handler: { _ in
            self.showChangeDefaultCurrency()
        })
        
        let changeIntervalAction = UIAlertAction(title: "Change Refresh Interval", style: .default, handler: { _ in
            self.showChangeInterval()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        menu.addAction(changeCurrencyAction)
        menu.addAction(changeIntervalAction)
        menu.addAction(cancelAction)
        present(menu, animated: true, completion: nil)
    }
    
}
