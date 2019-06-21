//
//  TZMModel.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit
import CoreData

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
        TZAPI().getDatas { [weak self] (success, response, error) in
            if success && error.count == 0 {
                
                self?.workWithCoreData(fromSrv: response, dataResult: { (success, resultArray) in
                    complete(success, resultArray, error)
                })
            } else {
                
            }
        }
    }
    
    func workWithCoreData(fromSrv: Any, dataResult: @escaping (Bool, Array<String>) -> ()) {
        
        checkInDB(with: fromSrv) { (success, array) in
            dataResult(true, array)
        }
        
//        newCurrency.setValue("USD", forKey: "name")
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed saving")
//        }
    }
    
    func checkInDB(with data: Any, complete: @escaping (Bool, Array<String>) -> ()) {
        
        deleteAllData("AllCurrency")
        deleteAllData("AllCurrencyServer")
        
        guard let ratesModel = data as? Rates else {
            return
        }
        
        var currencyModel: Currency!
        var normalArray: Array<String> = Array<String>()
        
        for i in 0..<(ratesModel.currens?.count)! {
            currencyModel = ratesModel.currens![i]
            if self.currencyExists(currency: currencyModel.name!) {
                print("Exists")
            } else {
                print("Not exists server")
                self.addToCoreData(currency: currencyModel.name!, value: currencyModel.value!)
            }
        }
        
        for i in 0..<(ratesModel.currens?.count)! {
            currencyModel = ratesModel.currens![i]
            if !normalArray.contains(currencyModel.name![0..<3]) {
                normalArray.append(currencyModel.name![0..<3])
            } else if !normalArray.contains(currencyModel.name![3..<(currencyModel.name?.count)!]) {
                normalArray.append(currencyModel.name![3..<(currencyModel.name?.count)!])
            }
        }
        
        for i in 0..<normalArray.count {
            currencyModel = ratesModel.currens![i]
            if self.currencyExists(currency: normalArray[i]) {
                print("Exists")
            } else {
                print("Not exists")
                self.addToCoreData(currency: normalArray[i], value: currencyModel.value!)
            }
        }
        
        complete(true, normalArray)
        
        
//        getCrossRate()
        
//        getFromCoreData(entity: "6") { (success, arra) in
//            print(arra)
//        }
//
//        getFromCoreData(entity: "3") { (success, arra) in
//            print(arra)
//        }
        
    }
    // MARK: - Work with core data
    func getFromCoreData(entity: String, results: @escaping (Bool, Array<Any>) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        var entityName = ""
        if entity == "3" {
            entityName = "AllCurrency"
        } else {
            entityName = "AllCurrencyServer"
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var array: Array<Any>! = []
            for data in result as! [NSManagedObject] {
                array.append(data)
            }
            results(true, array)
        } catch {
            print("Failed")
            results(false, Array<String>())
        }
    }
    
    func updateCoreData(with data: Array<String>) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AllCurrency")
        
        for i in 0..<data.count {
            request.predicate = NSPredicate(format: "name = %@", "\(data[i])")
            do {
                let result = try context.fetch(request)
                let objUpd = result[i] as! NSManagedObject
                objUpd.setValue(data[i], forKey: "name")
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func currencyExists(currency: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AllCurrency")
        if currency.count == 6 {
            fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AllCurrencyServer")
        }
        fetchRequest.predicate = NSPredicate(format: "name = %@", currency)
        var results: [NSManagedObject] = []
        
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
    
    func findCurrency(currency: String, result: (Bool, NSManagedObject?) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        var entity = "AllCurrency"
        if currency.count == 6 {
            entity = "AllCurrencyServer"
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "name = %@", currency)
//        var results: [NSManagedObject] = []
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count != 0 {
                let objUpd = results[0] as! NSManagedObject
                for data in results as! [NSManagedObject] {
                    print(data)
                }
                result(true, objUpd)
            } else {
                result(false, nil)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    func addToCoreData(currency: String, value: Double?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        var entityName = "AllCurrency"
        if currency.count == 6 {
            entityName = "AllCurrencyServer"
        }
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let newCurrency = NSManagedObject(entity: entity!, insertInto: context)
        
        newCurrency.setValue(currency, forKey: "name")
        if let value = value {
            newCurrency.setValue(value, forKey: "value")
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func deleteAllData(_ entity:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                appDelegate.persistentContainer.viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    func getValue(currency: String) -> Double {
        let val = 0.0
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let context = appDelegate.persistentContainer.viewContext
        var entityName = ""
//        if entity == "3" {
//            entityName = "AllCurrency"
//        } else {
            entityName = "AllCurrencyServer"
//        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "name = %@", currency)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count != 0 {
                let objUpd = result[0] as! NSManagedObject
                objUpd.value(forKey: "name")
                return objUpd.value(forKey: "value") as! Double
            } else {
                return val
            }
        } catch {
            print(error)
        }
        return val
    }
}

extension TZMModel {
    func calculate(value: Double, from: String, to: String) -> Double {
        
        var val = getValue(currency: from + to)
        print("normal: " + String(val))
        if val == 0.0 {
            val = getValue(currency: to + from)
            print("if 0: " + String(val))
        }
        
        if !currencyExists(currency: from + to) && !currencyExists(currency: to + from) {
            findCurrency(currency: from + to) { (success, object) in
                if success {
                    print(object)
                } else {
                    findCurrency(currency: from, result: { (success, object) in
                        print(object)
                    })
                }
            }
        }
        
        let first = value
        let sec = val
        
        let sum = first * sec
        
        return sum
    }
    
    func getCrossRate() {
        getFromCoreData(entity: "6") { (success, array) in
            //MARK:- You will find the array when its filter in "filteredStrings" variable you can check it by count if count > 0 its means you have find the results
            
            let itemsArray = ["EURUSD", "USDRUB", "EURRUB", "GBPUSD", "AUDUSD", "USDJPY", "NZDUSD", "USDCAD"]
            let searchToSearch = "USD"
            let searchToSearch1 = "EUR"
            let searchToSearch2 = "JPY"
            
            var filteredStrings = itemsArray.filter({(item: String) -> Bool in
                let stringMatch = item.lowercased().range(of: searchToSearch.lowercased())
                return stringMatch != nil ? true : false
            })
            
//            print(filteredStrings)
//            
//            filteredStrings = filteredStrings.filter({(item: String) -> Bool in
//                let stringMatch = item.lowercased().range(of: searchToSearch1.lowercased())
//                return stringMatch != nil ? true : false
//            })
//            
//            print(filteredStrings)
//            
//            filteredStrings = filteredStrings.filter({(item: String) -> Bool in
//                let stringMatch = item.lowercased().range(of: searchToSearch2.lowercased())
//                return stringMatch != nil ? true : false
//            })
//            
//            print(filteredStrings)
            
            print(array)
            
            
            if (filteredStrings as NSArray).count > 0
            {
                print(filteredStrings)
                //Record found
            }
            else
            {
                //Record Not found
            }
        }
    }
}
