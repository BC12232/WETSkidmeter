//
//  ReadFaultsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 5/15/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

struct FAULTS_DATA {
    var ethernetFault101 = 0
    var ethernetFault102 = 0
    var ethernetFault103 = 0
    var mw1pt1001Fault = 0
    var mw2pt1001Fault = 0
    var mw3pt1001Fault = 0
    var mw1pt1002Fault = 0
    var mw2pt1002Fault = 0
    var mw3pt1002Fault = 0
    var mw1pt1003Fault = 0
    var mw2pt1003Fault = 0
    var mw3pt1003Fault = 0
    var strainerFS101 = 0
    var strainerFS102 = 0
    var strainerFS103 = 0
    var strainerPSL1001 = 0
    var strainerPSL1002 = 0
    var strainerPSL1003 = 0
    var strainerPSL1004 = 0
    var strainerPSL1005 = 0
    var strainerPSL1006 = 0
    var strainerPSL1007 = 0
}


class ReadFaultsViewController: UIViewController {

    var faultsTag = 0
    var faultsData = FAULTS_DATA()
    var faultLabel = UILabel()
    var OffsetLbl = 30
    var counter4 = 1
    var counter3 = 1
    var counter2 = 1
    var counter1 = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        showFaults()

        // Do any additional setup after loading the view.
    }
    
    func showFaults(){
        switch faultsTag {
            case 1: if faultsData.ethernetFault101 == 0{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter1, index: 0)
                        counter1 += 1
                    }
                    if faultsData.mw1pt1001Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter1, index: 1)
                        counter1 += 1
                    }
                    if faultsData.mw1pt1002Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter1, index: 2)
                        counter1 += 1
                    }
                    if faultsData.mw1pt1003Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter1, index: 3)
                        counter1 += 1
                    }
            case 2: if faultsData.ethernetFault102 == 0{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter2, index: 4)
                        counter2 += 1
                    }
                    if faultsData.mw2pt1001Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter2, index: 5)
                        counter2 += 1
                    }
                    if faultsData.mw2pt1002Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter2, index: 6)
                        counter2 += 1
                    }
                    if faultsData.mw2pt1003Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter2, index: 7)
                        counter2 += 1
                    }
            case 3: if faultsData.ethernetFault103 == 0{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter3, index: 8)
                        counter3 += 1
                    }
                    if faultsData.mw3pt1001Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter3, index: 9)
                        counter3 += 1
                    }
                    if faultsData.mw3pt1002Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter3, index: 10)
                        counter3 += 1
                    }
                    if faultsData.mw3pt1003Fault == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter3, index: 11)
                        counter3 += 1
                    }
            case 4: if faultsData.strainerPSL1004 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 12)
                        counter4 += 1
                    }
                    if faultsData.strainerPSL1005 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 13)
                        counter4 += 1
                    }
                    if faultsData.strainerPSL1006 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 14)
                        counter4 += 1
                    }
                    if faultsData.strainerPSL1007 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 15)
                        counter4 += 1
                    }
                    if faultsData.strainerFS101 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 16)
                        counter4 += 1
                    }
                    if faultsData.strainerFS102 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 17)
                        counter4 += 1
                    }
                    if faultsData.strainerFS103 == 1{
                        customizeFaultLabel(x: 25, y: OffsetLbl*counter4, index: 18)
                        counter4 += 1
                    }
           
            default:
                print("INVALID TAG")
        }
       
    }
    
    private func customizeFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0,4,8:  faultLabel.text = "ETHERNET FAULT"
            case 1,5,9:  faultLabel.text = "PT1001 FAULT"
            case 2,6,10: faultLabel.text = "PT1002 FAULT"
            case 3,7,11: faultLabel.text = "PT1003 FAULT"
            case 12:     faultLabel.text = "PSL1004 FAULT"
            case 13:     faultLabel.text = "PSL1005 FAULT"
            case 14:     faultLabel.text = "PSL1006 FAULT"
            case 15:     faultLabel.text = "PSL1007 FAULT"
            case 16:     faultLabel.text = "FS 101 FAULT"
            case 17:     faultLabel.text = "FS 102 FAULT"
            case 18:     faultLabel.text = "FS 103 FAULT"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
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
