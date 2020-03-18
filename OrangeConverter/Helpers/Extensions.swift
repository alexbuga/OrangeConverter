//
//  Extensions.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor(named: "DarkPurple")
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension String {
    static func flag(forCountryCode code: String) -> String {
        return code
            .dropLast()
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    static func niceDate(fromTimeStamp stamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        let date = formatter.date(from: stamp)
        formatter.dateStyle = .medium
        return date != nil ? formatter.string(from: date!) : "Couldn't parse date"
    }
}

extension Int {
    func stringWithLeadingZero() -> String {
        return self < 10 ? "0\(self)" : "\(self)"
    }
}

extension Date {
    func apiFormat() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let year = components.year, let month = components.month, let day = components.day else {
            return ""
        }
        return "\(year)-\(month.stringWithLeadingZero())-\(day.stringWithLeadingZero())"
    }
}
