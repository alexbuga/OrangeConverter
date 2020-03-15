import UIKit

var str = "2020-03-13"

var formatter = DateFormatter()
formatter.dateFormat = "YYYY-MM-DD"
var date = formatter.date(from: str)!
formatter.dateStyle = .medium
var dateStr = formatter.string(from: date)
