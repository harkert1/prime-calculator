//
//  PrimeCalculator.swift
//  Primes
//
//  Created by Thomas Harker on 9/30/16.
//  Copyright © 2016 Thomas Harker. All rights reserved.
//

import Foundation

class PrimeCalculator {
    
    // The URL for my Amazon API Gateway
        static var postURL = "https://5an21ww6pi.execute-api.us-east-1.amazonaws.com/test/primecalc"
    
    /**
     - Parameters:
     - to: The end of the prime range.
     - from: The beginning of the prime range.
     - successHandler: The completion handler which has a string return value
     - Makes a POST request to my Amazon API Gateway URL
     - A JSON string is returned containing an array of all prime numbers in the range
     */
    static func request(to: Int, from: Int, successHandler: @escaping (_ response: NSArray) -> Void)->Void{
        let populatedDictionary = ["from": String(from), "to": String(to)];
        let data = populatedDictionary;
        let theJSONData = try? JSONSerialization.data(withJSONObject:
            data, options: .prettyPrinted);
        let jsonString = NSString(data: theJSONData!,
                                  encoding: String.Encoding.utf8.rawValue);
        let session = URLSession.shared;
        let urlPath:URL = URL(string: postURL)!;
        let request = NSMutableURLRequest(url: urlPath)
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData;
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST";
        let postLength = NSString(format:"%lu", jsonString!.length) as String
        request.setValue(postLength, forHTTPHeaderField:"Content-Length")
        request.httpBody = jsonString!.data(using: String.Encoding.utf8.rawValue, allowLossyConversion:true)
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if error == nil {
                let jsonDict: NSDictionary!  = try! JSONSerialization.jsonObject(with: data!,  options: []) as! NSDictionary;
                let list = jsonDict!["primes"] as! NSArray;
                successHandler(list as NSArray!);
            }
        }
        dataTask.resume()
    }


    
}
