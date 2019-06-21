//
//  TZMCoreDataWorker.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 21.06.2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit
import CoreData

class TZMCoreDataWorker: NSObject {
    static let coreDataShared = TZMCoreDataWorker()
    
    func workWithCoreData(fromSrv: Any, dataResult: @escaping (Bool, Array<Any>) -> ()) {
        
        if TZAPI().networkReachable() == true {
            checkInDB(with: fromSrv) { (success, array) in
                dataResult(true, array)
            }
        } else {
            getFromCoreData(entity: "6") { (success, result) in
                if success {
                    self.getFromCoreData(entity: "3", results: { (success, names) in
                        if success {
                            currencyNamesArray.append(contentsOf: names as! Array<String>)
                            dataResult(success, result)
                        } else {
                            // Not datas
                        }
                    })
                } else {
                    // Not datas
                }
            }
        }
        
    }
    
    func checkInDB(with data: Any, complete: @escaping (Bool, Array<String>) -> ()) {
        
        guard let ratesModel = data as? Rates else {
            return
        }

        var currencyModel: Currency!

        for i in 0..<(ratesModel.currens?.count)! {
            currencyModel = ratesModel.currens![i]
            if !currencyNamesArray.contains(currencyModel.name![0..<3]) {
                currencyNamesArray.append(currencyModel.name![0..<3])
            } else if !currencyNamesArray.contains(currencyModel.name![3..<(currencyModel.name?.count)!]) {
                currencyNamesArray.append(currencyModel.name![3..<(currencyModel.name?.count)!])
            }
            
            if self.currencyExists(currency: currencyNamesArray[i]) {
                
            } else {
                self.addToCoreData(currency: currencyNamesArray[i], value: nil)
            }
            
            if self.currencyExists(currency: currencyModel.name!) {
                print("Exists")
                self.refreshData(currency: currencyModel.name!, value: currencyModel.value!)
            } else {
                print("Not exists server")
                self.addToCoreData(currency: currencyModel.name!, value: currencyModel.value!)
            }
        }
        
        getFromCoreData(entity: "6") { (success, array) in
            complete(true, Array<String>())
        }
        
    }
    
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
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var array: Array<Any>! = []
            if entity == "3" {
                for data in result as! [NSManagedObject] {
                    array.append(data.value(forKey: "name") as! String)
                }
            } else {
                for data in result as! [NSManagedObject] {
                    array.append(data)
                }
            }
            results(true, array)
        } catch {
            print("Failed")
            results(false, Array<String>())
        }
    }
    
    func refreshData(currency: String, value: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AllCurrencyServer")
        
        request.predicate = NSPredicate(format: "name = %@", "\(currency)")
        do {
            let result = try context.fetch(request)
            let objUpd = result[0] as! NSManagedObject
            objUpd.setValue(value, forKey: "value")
            do {
                try context.save()
            } catch {
                print(error)
            }
            
        } catch {
            print(error)
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AllCurrencyServer")
        request.predicate = NSPredicate(format: "name = %@", currency)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count != 0 {
                let objUpd = result[0] as! NSManagedObject
                objUpd.value(forKey: "name")
                print(objUpd)
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
