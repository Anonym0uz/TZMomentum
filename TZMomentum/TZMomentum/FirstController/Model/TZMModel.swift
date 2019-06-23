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
        
        let fromValue = value
        var toValue = val
        var sum = fromValue * toValue
        if val == 0.0 {
            toValue = TZMCoreDataWorker.coreDataShared.getValue(currency: to + from)
            sum = fromValue / toValue
            if toValue == 0.0 {
                if !TZMCoreDataWorker.coreDataShared.currencyExists(currency: from + to) && !TZMCoreDataWorker.coreDataShared.currencyExists(currency: to + from) {
                    toValue = TZMCoreDataWorker.coreDataShared.getValue(currency: from + "USD")
                    if toValue == 0 {
                        toValue = TZMCoreDataWorker.coreDataShared.getValue(currency: "USD" + from)
                        sum = fromValue / toValue
                    } else {
                        sum = fromValue * toValue
                    }
                    toValue = TZMCoreDataWorker.coreDataShared.getValue(currency: "USD" + to)
                    if toValue == 0 {
                        toValue = TZMCoreDataWorker.coreDataShared.getValue(currency: to + "USD")
                        sum = sum / toValue
                    } else {
                        sum = toValue * sum
                    }
                }
            }
        }
        let sumStr = String(format: "%.4f", sum)
        return Double(sumStr)!
    }
}
