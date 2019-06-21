//
//  TZMModel.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit

var currencyNamesArray: Array<String> = Array<String>()

struct Rates: Decodable {
    private enum CodingKeys : String, CodingKey {
        case currens = "rates"
    }
    let currens: [Currency]?
}

struct Currency: Decodable {
    let name: String?
    let value: Double?
}

class TZMModel: NSObject {
    static let sharedModel = TZMModel()
    
    func getDatas(complete: @escaping (Bool, Any, String) -> ()) {
        TZAPI().getDatas { (success, response, error) in
            if success && error.count == 0 {
                complete(success, response, error)
            } else {

            }
        }
        
    }
    
    func calculate(value: Double, from: String, to: String) -> Double {
        
        let val = TZMCoreDataWorker.coreDataShared.getValue(currency: from + to)
        print("normal: " + String(val))
        
        let first = value
        var sec = val
        var sum = first * sec
        if val == 0.0 {
            sec = TZMCoreDataWorker.coreDataShared.getValue(currency: to + from)
            if sec == 0.0 {
                // Search in array
            }
            sum = first / sec
        }
        
        if !TZMCoreDataWorker.coreDataShared.currencyExists(currency: from + to) && !TZMCoreDataWorker.coreDataShared.currencyExists(currency: to + from) {
            print(TZMCoreDataWorker.coreDataShared.getValue(currency: from + "USD"))
            sec = TZMCoreDataWorker.coreDataShared.getValue(currency: from + "USD")
            if sec == 0 {
                sec = TZMCoreDataWorker.coreDataShared.getValue(currency: "USD" + from)
                sum = first / sec
            } else {
                sum = first * sec
            }
            print(TZMCoreDataWorker.coreDataShared.getValue(currency: "USD" + to))
            sec = TZMCoreDataWorker.coreDataShared.getValue(currency: "USD" + to)
            if sec == 0 {
                sec = TZMCoreDataWorker.coreDataShared.getValue(currency: to + "USD")
                sum = sum/sec
            } else {
                sum = sec * sum
            }
        }
        
        return sum
    }
}
