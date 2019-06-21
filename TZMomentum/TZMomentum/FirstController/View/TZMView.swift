//
//  TZMView.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit
import SnapKit

protocol TZMViewDelegate {
    func textFieldBeginEditing(textField: UITextField)
    func textFieldEndEditing(textField: UITextField)
    func textFieldReturnPressed(textField: UITextField)
    func calculate(count: Double, from: String, to: String)
}

class TZMView: UIView {
    
    var delegate: TZMViewDelegate?
    
    let changeCurrency1: UIButton = {
        let butt = UIButton()
        butt.tag = 1
        butt.setTitleColor(UIColor.black, for: .normal)
        butt.setTitle("EUR", for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.clipsToBounds = true
        butt.layer.cornerRadius = 10
        butt.layer.borderColor = UIColor.black.cgColor
        butt.layer.borderWidth = 1.0
        return butt
    }()
    
    let changeCurrency2: UIButton = {
        let butt = UIButton()
        butt.tag = 2
        butt.setTitleColor(UIColor.black, for: .normal)
        butt.setTitle("USD", for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.clipsToBounds = true
        butt.layer.cornerRadius = 10
        butt.layer.borderColor = UIColor.black.cgColor
        butt.layer.borderWidth = 1.0
        return butt
    }()
    
    let calculateButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Конвертировать", for: .normal)
        butt.setTitleColor(UIColor.black, for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.clipsToBounds = true
        butt.layer.cornerRadius = 10
        butt.layer.borderColor = UIColor.black.cgColor
        butt.layer.borderWidth = 1.0
        return butt
    }()
    
    let swapCurrencyButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Поменять", for: .normal)
        butt.setTitleColor(UIColor.black, for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.clipsToBounds = true
        butt.layer.cornerRadius = 10
        butt.layer.borderColor = UIColor.black.cgColor
        butt.layer.borderWidth = 1.0
        return butt
    }()
    
    let currencyTF1: UITextField = {
        let tf = UITextField()
        tf.tag = 1
        tf.text = "1"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1.0
        tf.leftView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 50))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 50))
        tf.rightViewMode = .always
        return tf
    }()
    
    let currencyTF2: UITextField = {
        let tf = UITextField()
        tf.tag = 2
        tf.placeholder = "Выходная валюта"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1.0
        tf.leftView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 50))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 50))
        tf.rightViewMode = .always
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(currencyChanged(sender:)), name: NSNotification.Name("CurrencyChanged"), object: nil)
        createViewElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViewElements() {
        changeCurrency1.addTarget(self, action: #selector(changeCurrencyClick(sender:)), for: .touchUpInside)
        changeCurrency2.addTarget(self, action: #selector(changeCurrencyClick(sender:)), for: .touchUpInside)
        calculateButton.addTarget(self, action: #selector(calculateClicked), for: .touchUpInside)
        swapCurrencyButton.addTarget(self, action: #selector(swapButtonClicked), for: .touchUpInside)
        addSubview(changeCurrency1)
        addSubview(changeCurrency2)
        currencyTF1.delegate = self
        currencyTF2.delegate = self
        addSubview(currencyTF1)
        addSubview(currencyTF2)
        addSubview(calculateButton)
        addSubview(swapCurrencyButton)
        
        changeCurrency1.snp.remakeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(self).offset(20)
            make.size.equalTo(CGSize(width: 60, height: 50))
        }
        
        currencyTF1.snp.remakeConstraints { (make) in
            make.left.equalTo(changeCurrency1.snp.right).offset(5)
            make.centerY.equalTo(changeCurrency1)
            make.right.equalTo(self).offset(-10)
            make.height.equalTo(changeCurrency1.snp.height)
        }
        
        swapCurrencyButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(currencyTF1.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        changeCurrency2.snp.remakeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(swapCurrencyButton.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: 60, height: 50))
        }
        
        currencyTF2.snp.remakeConstraints { (make) in
            make.left.equalTo(changeCurrency2.snp.right).offset(5)
            make.centerY.equalTo(changeCurrency2)
            make.right.equalTo(self).offset(-10)
            make.height.equalTo(changeCurrency2.snp.height)
        }
        
        calculateButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(currencyTF2.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
    }
    
    @objc fileprivate func changeCurrencyClick(sender: UIButton!) {
        NotificationCenter.default.post(name: NSNotification.Name("CurrencyNeedChange"), object: nil, userInfo: ["currencyNum" : sender.tag, "selectedCurrency" : (sender.titleLabel?.text)!])
    }
    
    @objc fileprivate func currencyChanged(sender: Notification) {
        if sender.userInfo!["currencyNum"] as! Int == 1 {
            changeCurrency1.setTitle(sender.userInfo!["currencyName"] as? String, for: .normal)
            if currencyTF1.text?.count == 0 {
                currencyTF1.text = String(1)
            }
        } else {
            changeCurrency2.setTitle(sender.userInfo!["currencyName"] as? String, for: .normal)
            if currencyTF1.text?.count == 0 {
                currencyTF1.text = String(1)
            }
        }
    }
    
    @objc fileprivate func calculateClicked() {
        self.delegate!.calculate(count: Double(currencyTF1.text!)!, from: (changeCurrency1.titleLabel?.text!)!, to: (changeCurrency2.titleLabel?.text!)!)
    }
    
    @objc fileprivate func swapButtonClicked() {
        let butt1Txt = self.changeCurrency1.titleLabel?.text
        let butt2Txt = self.changeCurrency2.titleLabel?.text
        
        self.changeCurrency1.setTitle(butt2Txt, for: .normal)
        self.changeCurrency2.setTitle(butt1Txt, for: .normal)
    }
}

extension TZMView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.textFieldBeginEditing(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.textFieldEndEditing(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.textFieldReturnPressed(textField: textField)
        if (currencyTF1.text?.count)! > 0 {
            calculateClicked()
        }
        return true
    }
}
