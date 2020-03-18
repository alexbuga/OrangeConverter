//
//  CurrencyCell.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var currencyTitle: UILabel!
    @IBOutlet weak var currencyDescription: UILabel!
    @IBOutlet weak var currencyValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: CurrencyCellViewModel) {
        currencyTitle?.text = viewModel.currencyCode
        currencyDescription.text = viewModel.currencyDescription
        currencyValue?.text = viewModel.currencyRate
    }

}
