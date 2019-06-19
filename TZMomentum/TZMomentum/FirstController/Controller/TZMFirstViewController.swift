//
//  TZMFirstViewController.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit

class TZMFirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Money converter"
        createView()
    }
    
    func createView() {
        view.backgroundColor = UIColor.white
        getCurrencyFromModel()
    }
    
    func getCurrencyFromModel() {
        TZMModel.sharedModel.getDatas { (success, response, error) in
            if success && error.count == 0 {
                print(response)
            }
        }
    }
}
