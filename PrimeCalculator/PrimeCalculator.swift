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
        static var postURL = "https://t7wg7l7j8i.execute-api.us-east-1.amazonaws.com/stage1/test"
    
    
    /**
     - Parameters:
     - to: The end of the prime range.
     - from: The beginning of the prime range.
     - successHandler: The completion handler which has a string return value
     - Makes a POST request to my Amazon API Gateway URL
     - A JSON string is returned containing an array of all prime numbers in the range
     */
    static func request(num: Int, successHandler: @escaping (_ response: PrimeResponse) -> Void)->Void{
        let populatedDictionary = ["num": String(num)];
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
                let prime = jsonDict!["prime"] as! Bool;
                let num = jsonDict!["num"] as! Int;
                let date = jsonDict!["date"] as! String;
                let resp = PrimeResponse(number: num, prime: prime, date: date);
                successHandler(resp);
            }
        }
        dataTask.resume()
    }


    
}
