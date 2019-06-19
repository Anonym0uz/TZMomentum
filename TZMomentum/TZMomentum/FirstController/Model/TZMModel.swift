//
//  TZMModel.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit

class TZMModel: NSObject {
    static let sharedModel = TZMModel()
    
    func getDatas(complete: @escaping (Bool, Any, String) -> ()) {
        TZAPI().getDatas { (success, response, error) in
            if success && error.count == 0 {
                complete(success, response, error)
            }
        }
    }
}

struct Rates: Decodable {
    let currens: [Currency]?
}

struct Currency: Decodable {
    let name: String?
    let value: Float?
}
