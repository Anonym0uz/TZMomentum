//
//  TZAPI.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 18/06/2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit

class TZAPI: NSObject {
    func getDatas(completeHandler: @escaping (Bool, Any, String) -> ()) {
        let urlString = "http://78.155.218.143/rates.json"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                print("\(error)")
                return
            }
            
            guard let data = data else { return }
            if self.networkReachable() == true {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    print(json)
                    
                    let jsonDecoded = try JSONDecoder().decode(Rates.self, from: data)
                    
                    DispatchQueue.main.async {
                        TZMCoreDataWorker.coreDataShared.workWithCoreData(fromSrv: jsonDecoded, dataResult: { (success, array) in
                            completeHandler(true, jsonDecoded, "")
                        })
                    }
                    
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            } else {
                DispatchQueue.main.async {
                    TZMCoreDataWorker.coreDataShared.workWithCoreData(fromSrv: Array<Any>(), dataResult: { (success, array) in
                        completeHandler(true, array, "")
                    })
                }
            }
            
            }.resume()
    }
}

extension TZAPI {
    open func networkReachable() -> Bool {
        let reachability = try! Reachability()
        
        var reach: Bool = false
        if reachability.connection == .wifi || reachability.connection == .cellular {
            reach = true
        } else {
            reach = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        return reach
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .unavailable:
            print("Network not reachable")
        case .none:
            print("none")
        }
    }
}
