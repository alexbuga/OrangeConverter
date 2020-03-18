//
//  HistoryViewController.swift
//  OrangeConverter
//
//  Created by Alex Buga on 16/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var currencies = ["RON", "USD", "BGN"]
    @IBOutlet weak var tableView: UITableView!
    
    var historyDataSource: HistoryDataSource!
    var historyViewModel: HistoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "HistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "row")
        historyDataSource = HistoryDataSource()
        historyDataSource.data.addObserver(self, andNotify: true) { [weak self] items in
            self?.tableView.reloadData()
        }
        tableView.dataSource = historyDataSource
        tableView.delegate = historyDataSource
        
        let service = CurrencyService()
        historyViewModel = HistoryViewModel(service: service, dataSource: historyDataSource)
        historyViewModel.handleError = { error in
            self.showAlert(title: "Oops", message: error?.localizedDescription)
        }
        historyViewModel.fetchHistory(forCurrencies: currencies)
        
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowRadius = 10
        tableView.layer.shadowOffset.height = 2
    }
    
    deinit {
        let _ = historyDataSource.data.removeObserver(self)
    }
}
