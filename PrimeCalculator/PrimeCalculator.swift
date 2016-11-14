//
//  PrimeCalculator.swift
//  Primes
//
//  Created by Thomas Harker on 9/30/16.
//  Copyright © 2016 Thomas Harker. All rights reserved.
//
import Foundation
import AWSS3
import AWSCognito
import AWSCore

class PrimeCalculator {
    
    // The URL for my Amazon API Gateway
        static var postURL = "https://zq7d6or2z0.execute-api.us-west-2.amazonaws.com/1/test"
        static var fileName = "prime"
    
    
    static func request2(to: Int, from: Int, successHandler: @escaping (_ response: String) -> Void) -> Void {
        let file = createFileURL(to: to, from: from);
                let session = URLSession.shared;
                let urlPath:URL = URL(string: postURL)!;
                let request = NSMutableURLRequest(url: urlPath)
                
                request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData;
                request.httpMethod = "POST";
                
        let dataTask = session.uploadTask(with: request as URLRequest, from: NSData(contentsOfFile: file.path) as Data?){ (data:Data?, response:URLResponse?, error:Error?) -> Void in
                    if error == nil {
                        successHandler(String(data: data!, encoding: String.Encoding.utf8)!);
                    }
                }
                dataTask.resume()
    }
    
    static func createFileURL(to: Int, from: Int) -> URL
    {
        var writeString = ""
        for i in from ... to {
            writeString.append(String(i));
            writeString.append(" \n");
        }
        
        let docDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirectory!.appendingPathComponent(PrimeCalculator.fileName).appendingPathExtension("txt")
        
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            print(error.description)
        }
        return fileURL;
    }


    
}
