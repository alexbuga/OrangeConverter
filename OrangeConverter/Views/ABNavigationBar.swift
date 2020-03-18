//
//  ABNavigationBar.swift
//  OrangeConverter
//
//  Created by Alex Buga on 18/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class ABNavigationBar: UINavigationBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        let image = UIImage(named: "header-gradient")!
        barTintColor = UIColor(patternImage: image)
        tintColor = .white
        isTranslucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Futura", size: 14)!], for: .normal)
    }

}
