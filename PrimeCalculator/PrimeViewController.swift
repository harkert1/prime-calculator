//
//  PrimeViewController.swift
//  Primes
//
//  Created by Thomas Harker on 9/27/16.
//  Copyright © 2016 Thomas Harker. All rights reserved.
//

import UIKit

class PrimeViewController: UIViewController {
    
    @IBOutlet weak var fromInput: UITextField!
    @IBOutlet weak var toInput: UITextField!
    @IBOutlet weak var primeOutput: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     - Validates the input in the two UITextFields
        - Input should be an integer
        - If input invalid, displays UIAlert
     - If input is valid, PrimeCalculator.request(to, from) to get the range of primes for this input
     - The response, an array containing the specified prime range, is captured in the completion handler of PrimeCalculator.request
     - The contents of the array are converted to String for display in the primeOutput UITextView (asynchronously)
     */
    @IBAction func getPrimes() {
        let from = fromInput.text;
        let to = toInput.text;
        var invalidInput = false;
        if let intTo = Int(to!)
        {
            if let intFrom = Int(from!) {
                //let primes = PrimeCalculator.getPrimes(to: intTo, from: intFrom);
                //requestPrimes(to: intTo, from: intFrom);
                PrimeCalculator.request(to: intTo, from: intFrom){ (_response) -> Void in
                    DispatchQueue.main.async(execute: {
                        // Format the NSArray into a string to display.
                        var txt = "";
                        for nums in _response {
                            txt.append(String(describing: nums));
                            txt.append(" ");
                        }
                        self.primeOutput.text = txt;
                    })
                };
            }
            else {
                invalidInput = true;
            }
        }
        else {
            invalidInput = true;
        }
        if invalidInput {
            let alert = UIAlertController(title: "Alert", message: "Input must be numeric.", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Close", style:UIAlertActionStyle.default, handler:nil));
            self.present(alert, animated:true, completion: nil);
        }
        
        
    }
}

