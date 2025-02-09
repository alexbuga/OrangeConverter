
//
//  CurrencyDataSource.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class CurrencyDataSource: DynamicDataSource<CurrencyRate>, UITableViewDataSource, UITableViewDelegate {
    
    var date = "Loading date..."
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rate = data.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "row") as! CurrencyCell
        let viewModel = CurrencyCellViewModel(rate: rate)
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
