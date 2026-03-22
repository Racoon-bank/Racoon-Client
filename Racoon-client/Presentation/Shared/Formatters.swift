//
//  Formatters.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//

import Foundation

enum Formatters {

    static func money(_ value: Decimal?) -> String {
        guard let value else { return "—" }
   
        return NSDecimalNumber(decimal: value).stringValue 
    }
    
    static func percent(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value * 100)
        return number.stringValue + " %"
    }
}
