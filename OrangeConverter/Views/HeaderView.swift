//
//  HeaderView.swift
//  OrangeConverter
//
//  Created by Alex Buga on 18/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: NSObject {
    func headerView(didTapButton type: HeaderView.ButtonType)
}

@IBDesignable class HeaderView: UIView {
    
    enum ButtonType: Int {
        case history
        case settings
    }
    
    weak var delegate: HeaderViewDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        delegate?.headerView(didTapButton: sender == historyButton ? .history : .settings)
    }
    
    private func setupView() {
        guard let nib = Bundle(for: type(of: self)).loadNibNamed("HeaderView", owner: self, options: nil)?.first as? UIView else {return}
        nib.frame = bounds
        nib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(nib)
    }
}
