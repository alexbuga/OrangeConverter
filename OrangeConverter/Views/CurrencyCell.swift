//
//  CurrencyCell.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: CurrencyCellViewModel) {
        textLabel?.text = viewModel.currencyCode
        detailTextLabel?.text = viewModel.currencyRate
    }

}
