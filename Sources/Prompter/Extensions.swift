//
//  Extensions.swift
//  swift-cli
//
//  Created by Matthew on 11/01/2016.
//  Copyright © 2016 Matthew Clarkson. All rights reserved.
//

extension String {

    public var bool: Bool? {

        switch self.lowercased() {
        case "true", "t", "y", "yes", "1":
            return true
        case  "false", "f", "n", "no", "0":
            return false
        default:
            return nil
        }
    }

    public var int: Int? {
        return Int(self)
    }
}

extension Array {

    public func getAt(index: Int?) -> Element? {
        guard let index = index, 
            0 <= index && index <= count - 1
        else { 
            return nil 
        }
        return index <= self.count - 1 
            ? self[index] 
            : nil
    }
}
