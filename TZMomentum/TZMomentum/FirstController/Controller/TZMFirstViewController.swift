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
    var pickerHide: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        createKVOServers()
        let updateButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getCurrencyFromModel))
        TZFunctions().setupNavigationController(navigationCtrl: self.navigationController, navigationItem: self.navigationItem, navigationTitle: "Money converter", leftButton: nil, rightButton: updateButton)
        createView()
    }
    
    fileprivate func createKVOServers() {
        NotificationCenter.default.addObserver(self, selector: #selector(currencyNeedChange(sender:)), name: NSNotification.Name("CurrencyNeedChange"), object: nil)
    }
    
    func createView() {
        view.backgroundColor = UIColor.white
        
        let hideGest = UITapGestureRecognizer(target: self, action: #selector(hideGesture))
        view.addGestureRecognizer(hideGest)
        
        mview = TZMView(frame: .zero)
        mview.delegate = self
        view.addSubview(mview)
        
        pickerView = UIPickerView(frame: .zero)
        pickerView.backgroundColor = UIColor.lightGray
        pickerView.dataSource = self
        pickerView.delegate = self
        view.addSubview(pickerView)
        
        mview.snp.remakeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        getCurrencyFromModel()
    }
    
    @objc fileprivate func currencyNeedChange(sender: Notification) {
        if currencyChange == sender.userInfo!["currencyNum"] as! Int && pickerHide == false {
            showPickerView(false, data: sender.userInfo!)
        } else {
            showPickerView(true, data: sender.userInfo!)
        }
        currencyChange = sender.userInfo!["currencyNum"] as! Int
    }
    
    fileprivate func showPickerView(_ show: Bool, data: Any) {
        if show {
            view.endEditing(true)
            if currencyChange == 1 {
                self.pickerView.selectRow(currencyNamesArray.index(of: (data as! [AnyHashable : Any])["selectedCurrency"] as! String)!, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(currencyNamesArray.index(of: (data as! [AnyHashable : Any])["selectedCurrency"] as! String)!, inComponent: 0, animated: true)
            }
        }
        pickerHide = !show
        view.updateConstraintsIfNeeded()
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.05) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if pickerHide {
            pickerView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(0)
            }
        } else {
            pickerView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(view)
                make.left.right.equalTo(view)
                make.height.equalTo(220)
            }
        }
    }
    
    // MARK: - Buttons handler
    @objc func getCurrencyFromModel() {
        hideGesture()
        IJProgressView.shared.showProgressView()
        TZMModel.sharedModel.getDatas { (success, response, error) in
            if success && error.count == 0 {
                self.animateNavBar(title: "Успех!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    IJProgressView.shared.hideProgressView()
                    self.animateNavBar(title: "Money converter")
                })
            } else {
                let alert = UIAlertController(title: "TZMomentum", message: "Ошибка при получении данных,\rпопробуйте обновить позднее.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Animations for nav title
    func animateNavBar(title: String) {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.2
        fadeTextAnimation.type = CATransitionType.fade
        self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        self.navigationItem.title = title
    }
    
    // MARK: - Hide gesture
    @objc func hideGesture() {
        view.endEditing(true)
        showPickerView(false, data: [:])
    }
}

extension TZMFirstViewController: TZMViewDelegate {
    func calculate(count: Double, from: String, to: String) {
        let calculateCount = TZMModel.sharedModel.calculate(value: count, from: from, to: to)
        mview.currencyTF2.text = String(calculateCount)
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
