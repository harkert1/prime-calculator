//
//  PrimeResponse.swift
//  PrimeCalculator
//
//  Created by Thomas Harker on 10/30/16.
//  Copyright © 2016 Thomas Harker. All rights reserved.
//

import Foundation

class PrimeResponse {
    var number: Int!
    var prime: Bool!
    var date: String!
    
    init(number: Int, prime: Bool, date: String) {
        self.number = number;
        self.prime = prime;
        self.date = date;
    }
    
    func getNum() -> Int {
        return number;
    }
    
    func getPrime() -> Bool {
        return prime;
    }
    
    func getDate() -> String {
        return date;
    }
}
