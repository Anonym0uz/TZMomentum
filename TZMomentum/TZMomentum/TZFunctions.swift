//
//  TZFunctions.swift
//  TZMomentum
//
//  Created by Alexander Orlov on 19.06.2019.
//  Copyright © 2019 Alexander Orlov. All rights reserved.
//

import UIKit
import Foundation

class TZFunctions {
    
    // MARK: - Setup Navigation Controller
    func setupNavigationController(navigationCtrl: UINavigationController!,
                                   navigationItem: UINavigationItem!,
                                   navigationTitle: String,
                                   hideBackButton: Bool = false,
                                   leftButton: UIBarButtonItem?,
                                   rightButton: UIBarButtonItem?) -> Void {
        navigationItem.title = navigationTitle
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationCtrl.navigationBar.barTintColor = UIColor.white
        navigationCtrl.navigationBar.isTranslucent = false
        navigationCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        if hideBackButton {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        }
    }
    
    // MARK: - Logger
    public func CustomLog<T>(_ object: T, _ file: String = #file, function: String = #function, line: Int = #line, trace: [String] = Thread.callStackSymbols) {
        let fileString: NSString = NSString(string: file)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"
        let process = ProcessInfo.processInfo
        let traceOutput: String = trace.map { "\t\t\($0)" }.reduce("\n") { "\($0)\n\($1)" }
        let output: String =  object is Error ? "\((object as! Error).localizedDescription)\(traceOutput)" : "\(object)"
        print("‼️ [\(process.processName)] \(dateFormatter.string(from: Foundation.Date())) ‼️" + "\n" + "[PRDLog -->] File: \(fileString.lastPathComponent)" + "\n" + "[CstLog -->] Function: \(function)" + "\n" + "[PRDLog -->] Line: \(line)" + "\r[PRDLog -->] Description: \r\(output)")
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
