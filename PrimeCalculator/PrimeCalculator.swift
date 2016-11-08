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
        static var postURL = "https://drfcw8n55h.execute-api.us-west-2.amazonaws.com/s3reader/test"
        static var fileName = "prime"
        static var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    
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
    
    static func request2(to: Int, from: Int, successHandler: @escaping (_ response: String) -> Void) -> Void {
        let file = createFileURL(to: to, from: from);
        uploadToS3(fileURL: file) { (response) -> Void in
            if response {
                let populatedDictionary = ["key": file.lastPathComponent];
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
                        let jsonDict: NSDictionary! = try! JSONSerialization.jsonObject(with: data!,  options: []) as! NSDictionary;
                        let retString = jsonDict!["primes"] as! NSString;
                        successHandler(retString as String);
                    }
                }
                dataTask.resume()
            }
            else {
                successHandler("Failed with error.");
            }
        };
    }
    
    static func uploadToS3(fileURL: URL, successHandler: @escaping (_ reponse: Bool) -> Void) ->Void {
        let S3BucketName = "myprimeuploads2"
        
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = fileURL.lastPathComponent
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "text/plain"
        
        self.uploadCompletionHandler = { (task, error) -> Void in
                if ((error) != nil){
                    print("Failed with error")
                    print("Error: \(error!)");
                }
                else{
                    print("Sucess")
                }
        }
        
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile(fileURL, bucket: S3BucketName, key: fileURL.lastPathComponent, contentType: "text/plain", expression: AWSS3TransferUtilityUploadExpression(), completionHander: uploadCompletionHandler).continue({ (task) -> AnyObject! in
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
                successHandler(false);
            }
            if let exception = task.exception {
                NSLog("Exception: %@",exception.description);
                successHandler(false);
            }
            if let _ = task.result {
                NSLog("Upload Starting!")
                successHandler(true);
            }
            else {
                successHandler(false);
            }
            
            return nil;
        })
    
        //let transferManager = AWSS3TransferManager.default()
        //transferManager?.upload(uploadRequest).continue(with: AWSExecutor.mainThread(), withSuccessBlock: { (task: AWSTask) -> Any? in
          //  if task.error != nil {
            //    successHandler(false)
            //}
            //else {
              //  let s3URL = NSURL(string: "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest.key!)")!
            //    print("Uploaded to:\n\(s3URL)")
            //   successHandler(true)
            //    }
            //return nil
            //        })
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
