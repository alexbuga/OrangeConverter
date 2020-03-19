//
//  HistoryCell.swift
//  OrangeConverter
//
//  Created by Alex Buga on 16/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var chartView: ABChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withViewModel viewModel: HistoryCellViewModel) {        
        chartView.chartMode = .Graph
        chartView.title = viewModel.title
        chartView.setData(columnNames: viewModel.columnNames, columnValues: viewModel.values)
    }
    
}
