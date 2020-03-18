//
//  ErrorHandlingViewModel.swift
//  OrangeConverter
//
//  Created by Alex Buga on 18/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation

protocol ErrorHandling {
    var handleError: ((Error?)->Void)? { get }
}
