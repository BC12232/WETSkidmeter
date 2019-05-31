//
//  ReadSepointsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 5/30/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class ReadSepointsViewController: UIViewController {
    var faultsTag = 0
   
    @IBOutlet weak var pt1001lbl: UILabel!
    @IBOutlet weak var scaledVal: UILabel!
    @IBOutlet weak var channelFault: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch faultsTag {
            case 201:
                self.pt1001lbl.text = "PT1001"
                self.readSetpoints(startingRegister: 5000, faultRegister: 5000)
            case 202:
                self.pt1001lbl.text = "PT1002"
                self.readSetpoints(startingRegister: 5020, faultRegister: 5020)
            case 203:
                self.pt1001lbl.text = "PT1003"
                self.readSetpoints(startingRegister: 5040, faultRegister: 5040)
            default:
                print("NO TAG")
        }
    }
    
    func readSetpoints(startingRegister:Int,faultRegister:Int){
        
        CENTRAL_SYSTEM?.readRealRegister(register: startingRegister, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let scaledVal = Float(response)
            self.scaledVal.text =  String(format: "%.1f", scaledVal!)
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(faultRegister), completion: { (success, response) in
            guard success == true else { return }
            let status  = Int(truncating: response![0] as! NSNumber)
            if status == 0{
                self.channelFault.isHidden = true
            } else {
                self.channelFault.isHidden = false
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
