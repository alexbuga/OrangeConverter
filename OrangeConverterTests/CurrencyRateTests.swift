//
//  CurrencyRateTests.swift
//  OrangeConverterTests
//
//  Created by Alex Buga on 18/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import XCTest
@testable import OrangeConverter

class CurrencyRateTests: XCTestCase {
    
    func testCurrencyNilWithLongerName() {
        let rate = CurrencyRate(currencyCode: "USDF", rate: 2.0)
        XCTAssertTrue(rate == nil)
    }
    
    func testCurrencyNilWithShorterName() {
        let rate = CurrencyRate(currencyCode: "US", rate: 2.0)
        XCTAssertTrue(rate == nil)
    }
    
    func testCurrencyNilWithInvalidChars() {
        let rate = CurrencyRate(currencyCode: "U5D", rate: 2.0)
        XCTAssertTrue(rate == nil)
    }
    
    func testCurrencyNilWithInvalidRate() {
        let rate = CurrencyRate(currencyCode: "USD", rate: 0)
        XCTAssertTrue(rate == nil)
    }
    
}
