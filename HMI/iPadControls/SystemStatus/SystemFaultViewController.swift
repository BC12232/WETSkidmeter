//
//  SystemFaultViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 12/13/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class SystemFaultViewController: UIViewController {

    @IBOutlet weak var nameOfFaultLabel: UILabel!
    var faultIndex: [Int]?
    var strainerFaultIndex: [Int]?
    var faultTag = 0
    var faultLabel = UILabel()
    var strainerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if faultTag == 200{
             nameOfFaultLabel.text = "NETWORK FAULT"
            nameOfFaultLabel.textAlignment = .center
             readNetworkFaults()
        } else {
            nameOfFaultLabel.text = "CLEAN STRAINER"
            nameOfFaultLabel.textAlignment = .left
            readStarinerFaults()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if faultTag == 100{
            faultLabel.removeFromSuperview()
            faultIndex?.removeAll()
        } else {
            strainerLabel.removeFromSuperview()
            strainerFaultIndex?.removeAll()
        }
       
    }
    
    private func readNetworkFaults() {
        let offset = 30
        
        for (index,value) in faultIndex!.enumerated() {
            
            switch index {
            case 0...9:
                customizeFaultLabel(x: 20, y: (95 + (index * offset)), index: value)
            case 10...19:
                customizeFaultLabel(x: 125, y: (95 + ((index - 10) * offset)), index: value)
            case 20...29:
                customizeFaultLabel(x: 230, y: (95 + ((index - 20) * offset)), index: value)
            case 30...34:
                customizeFaultLabel(x: 335, y: (95 + ((index - 30) * offset)), index: value)
            default:
                print("Wrong index")
            }
            
        }
    }
    
    private func readStarinerFaults() {
        for (index,value) in strainerFaultIndex!.enumerated() {
            let offset = 30
            
            switch index {
                case 0...10:
                    customizeStrainerFaultLabel(x: 25, y: (95 + (index * offset)), index: value)
                default:
                    print("Wrong index")
                }
        }
    }
    
    private func customizeFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 100, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0:   faultLabel.text = "VFD-101"
            case 1:   faultLabel.text = "VFD-201"
            case 2:   faultLabel.text = "VFD-202"
            case 3:   faultLabel.text = "VFD-203"
            case 4:   faultLabel.text = "VFD-204"
            case 5:   faultLabel.text = "VFD-205"
            case 6:   faultLabel.text = "VFD-206"
            case 7:   faultLabel.text = "VFD-207"
            case 8:   faultLabel.text = "VFD-208"
            case 9:   faultLabel.text = "VFD-209"
            case 10:  faultLabel.text = "VFD-210"
            case 11:  faultLabel.text = "VFD-211"
            case 12:  faultLabel.text = "VFD-212"
            case 13:  faultLabel.text = "VFD-301"
            case 14:  faultLabel.text = "VFD-302"
            case 15:  faultLabel.text = "VFD-303"
            case 16:  faultLabel.text = "VFD-304"
            case 17:  faultLabel.text = "VFD-305"
            case 18:  faultLabel.text = "VFD-306"
            case 19:  faultLabel.text = "VFD-401"
            case 20:  faultLabel.text = "VFD-402"
            case 21:  faultLabel.text = "VFD-403"
            case 22:  faultLabel.text = "VFD-404"
            case 23:  faultLabel.text = "VFD-405"
            case 24:  faultLabel.text = "VFD-406"
            case 25:  faultLabel.text = "VFD-407"
            case 26:  faultLabel.text = "VFD-408"
            case 27:  faultLabel.text = "VFD-409"
            case 28:  faultLabel.text = "VFD-410"
            case 29:  faultLabel.text = "VFD-411"
            case 30:  faultLabel.text = "VFD-412"
            case 31:faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 20))
                    faultLabel.textAlignment = .center
                    faultLabel.textColor = RED_COLOR
                    faultLabel.text = "REMOTEIO_MCC-401"
            case 32:faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 20))
                    faultLabel.textAlignment = .center
                    faultLabel.textColor = RED_COLOR
                    faultLabel.text = "REMOTEIO_MCC-402"
            case 33:faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 20))
                    faultLabel.textAlignment = .center
                    faultLabel.textColor = RED_COLOR
                    faultLabel.text = "REMOTEIO_MCC-403"
            case 34:faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 20))
                    faultLabel.textAlignment = .center
                    faultLabel.textColor = RED_COLOR
                    faultLabel.text = "REMOTEIO_MCC-404"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
    }
    
    private func customizeStrainerFaultLabel(x: Int, y: Int, index: Int) {
        strainerLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        strainerLabel.textAlignment = .center
        strainerLabel.textColor = RED_COLOR
        switch index {
            case 0:  strainerLabel.text = "F101 STRAINER"
            case 1:  strainerLabel.text = "F103 STRAINER"
            case 2:  strainerLabel.text = "F104 STRAINER"
            case 3:  strainerLabel.text = "F105 STRAINER"
            case 4:  strainerLabel.text = "F106 STRAINER"
            case 5:  strainerLabel.text = "F107 STRAINER"
            case 6:  strainerLabel.text = "F108 STRAINER"
            case 7:  strainerLabel.text = "F109 STRAINER"
            case 8:  strainerLabel.text = "F110 STRAINER"
            case 9:  strainerLabel.text = "F111 STRAINER"
            case 10:  strainerLabel.text = "F112 STRAINER"
        default:
            print("Wrong index")
        }
       
        self.view.addSubview(strainerLabel)
    }

    
}
