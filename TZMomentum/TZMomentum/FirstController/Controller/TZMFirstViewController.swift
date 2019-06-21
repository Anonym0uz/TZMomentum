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
        let updateButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getCurrencyFromModel))
        TZFunctions().setupNavigationController(navigationCtrl: self.navigationController, navigationItem: self.navigationItem, navigationTitle: "Money converter", leftButton: nil, rightButton: updateButton)
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
        showPickerView(true, data: sender.userInfo!)
    }
    
    fileprivate func showPickerView(_ show: Bool, data: Any) {
        if show {
            view.endEditing(true)
            view.addSubview(pickerView)
            pickerView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(view)
                make.left.right.equalTo(view)
            }
            if currencyChange == 1 {
                self.pickerView.selectRow(currencyNamesArray.index(of: (data as! [AnyHashable : Any])["selectedCurrency"] as! String)!, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(currencyNamesArray.index(of: (data as! [AnyHashable : Any])["selectedCurrency"] as! String)!, inComponent: 0, animated: true)
            }
        } else {
            pickerView.removeFromSuperview()
        }
    }
    
    // MARK: - Buttons handler
    @objc func getCurrencyFromModel() {
        IJProgressView.shared.showProgressView()
        TZMModel.sharedModel.getDatas { (success, response, error) in
            if success && error.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    IJProgressView.shared.hideProgressView()
                })
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
        showPickerView(false, data: [:])
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
        return currencyNamesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(#function)
        print(currencyNamesArray[row])
        NotificationCenter.default.post(name: NSNotification.Name("CurrencyChanged"), object: nil, userInfo: ["currencyNum" : currencyChange, "currencyName" : currencyNamesArray[row]])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyNamesArray[row]
    }
}
