//
//  ViewController.swift
//  call3
//
//  Created by huy on 28/02/2023.
//

import UIKit
import PushKit
import CallKit

class ViewController: UIViewController, CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
        print("test --")
    }
    
    
    var callUUID: UUID?
    var provider: CXProvider?
    var callController = CXCallController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func buttonPress(_ sender: UIButton) {
        print("express");
        
        let uuidString = "FA816409-B25F-42A3-800B-465A55CF7C13"
    
            let endCallAction = CXEndCallAction(call: GlobalVariables.callId);
                   let transaction = CXTransaction(action: endCallAction)
                   callController.request(transaction) { error in
                       if let error = error {
                           print(" handle error")
                           // Handle error
                       } else {
                           
                           print("successfully");
                           // Call ended successfully
                       }
                   }
     
        
    
    }
}

