//
//  TZMFirstViewController.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit
import SnapKit

class TZMFirstViewController: UIViewController {
    
    var mview: TZMView!
    var pickerView: UIPickerView!
    var pickerTitles: Array<String> = Array<String>()
    var currencyChange = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        createKVOServers()
        TZFunctions().setupNavigationController(navigationCtrl: self.navigationController, navigationItem: self.navigationItem, navigationTitle: "Money converter", leftButton: nil, rightButton: nil)
//        TZMModel.sharedModel.workWithCoreData()
        createView()
    }
    
    fileprivate func createKVOServers() {
        NotificationCenter.default.addObserver(self, selector: #selector(currencyNeedChange(sender:)), name: NSNotification.Name("CurrencyNeedChange"), object: nil)
    }
    
    func createView() {
        view.backgroundColor = UIColor.white
        mview = TZMView(frame: .zero)
        mview.delegate = self
        view.addSubview(mview)
        
        pickerView = UIPickerView(frame: .zero)
        pickerView.backgroundColor = UIColor.lightGray
        pickerView.dataSource = self
        pickerView.delegate = self
        
        mview.snp.remakeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        getCurrencyFromModel()
    }
    
    @objc fileprivate func currencyNeedChange(sender: Notification) {
        currencyChange = sender.userInfo!["currencyNum"] as! Int
        showPickerView(true)
    }
    
    fileprivate func showPickerView(_ show: Bool) {
        if show {
            view.addSubview(pickerView)
            pickerView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(view)
                make.left.right.equalTo(view)
            }
            if currencyChange == 1 {
//                self.pickerView.selectRow(1, inComponent: 1, animated: true)
            } else {
//                self.pickerView.selectRow(1, inComponent: 1, animated: true)
            }
        } else {
            pickerView.removeFromSuperview()
        }
    }
    
    // MARK: - Buttons handler
    func getCurrencyFromModel() {
        
//        TZMModel.sharedModel.getFromCoreData { (success, array) in
//            print(array)
//        }
        
        TZMModel.sharedModel.getDatas { (success, response, error) in
            if success && error.count == 0 {
                self.pickerTitles = response as! Array
                DispatchQueue.main.async {
                    self.pickerView.reloadAllComponents()
                }
            }
        }
    }
}

extension TZMFirstViewController: TZMViewDelegate {
    func calculate(count: Double, from: String, to: String) {
        let cooo = TZMModel.sharedModel.calculate(value: count, from: from, to: to)
        print(cooo)
        mview.currencyTF2.text = String(cooo)
    }
    
    func textFieldBeginEditing(textField: UITextField) {
        print(#function)
        showPickerView(false)
    }
    
    func textFieldEndEditing(textField: UITextField) {
        print(#function)
    }
    
    func textFieldReturnPressed(textField: UITextField) {
        print(#function)
        textField.resignFirstResponder()
    }
    
    
}

extension TZMFirstViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(#function)
        print(pickerTitles[row])
        NotificationCenter.default.post(name: NSNotification.Name("CurrencyChanged"), object: nil, userInfo: ["currencyNum" : currencyChange, "currencyName" : pickerTitles[row]])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerTitles[row]
    }
}
