//
//  GenericDataSource.swift
//  OrangeConverter
//
//  Created by Alex Buga on 15/03/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class DynamicData<T> {
    var value: T {
        didSet {
            notifyObservers()
        }
    }
    
    private var observers = [String: CompletionBlock<T>]()
    
    init(_ value: T) {
        self.value = value
    }
    
    private func notifyObservers() {
        observers.forEach { _, block in
            block(value)
        }
    }
    
    public func addObserver(_ observer: NSObject, andNotify: Bool = false, _ completionHandler: @escaping CompletionBlock<T>) {
        observers[observer.description] = completionHandler
        if andNotify {
            self.notifyObservers()
        }
    }
    
    public func removeObserver(_ observer: NSObject) -> Bool {
        return observers.removeValue(forKey: observer.description) != nil
    }
    
    deinit {
        observers.removeAll()
    }
}

class DynamicDataSource<T>: NSObject {
    var data: DynamicData<[T]>! = DynamicData([])
}
