//
//  HistoryItemTests.swift
//  OrangeConverterTests
//
//  Created by Alex Buga on 19/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import XCTest
@testable import OrangeConverter

class HistoryItemTests: XCTestCase {

    func testCurrencyNilWithLongerName() {
        let item = HistoryItem(currencyCode: "USDF")
        XCTAssertTrue(item == nil)
    }
    
    func testCurrencyNilWithShorterName() {
        let item = HistoryItem(currencyCode: "US")
        XCTAssertTrue(item == nil)
    }
    
    func testCurrencyNilWithInvalidChars() {
        let item = HistoryItem(currencyCode: "U5D")
        XCTAssertTrue(item == nil)
    }
    
    func testAddHistoryItemWithInvalidDate() {
        guard
            let item = HistoryItem(currencyCode: "USD"),
            let rate = CurrencyRate(currencyCode: "USD", rate: 2.43)
        else {
            XCTFail("Could not initialize models");
            return
        }
            
        let date = "2020-13-01"
        let added = item.add(currencyRate: rate, forDate: date)
        XCTAssertFalse(added)
    }

}
