// THIS IS THE WORKING VERSION.
//  View2Controller.swift
//  WETSkidmeter4
//
//  Created by Bethany Chen on 8/2/19.
//  Copyright © 2019 Bethany Chen. All rights reserved.
//

import UIKit

class View2Controller: UIViewController{
    
    @IBOutlet weak var autoRB: DLRadioButton!
    @IBOutlet weak var manualRB: DLRadioButton!
    @IBOutlet weak var titleTester: UITextView!
    
    //Tester for reading registers. Not "installed" currently.
    @IBOutlet weak var textViewTester: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //helper to turn active = blue + selected
    func setActive(curr: DLRadioButton){
        curr.iconColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 100)
        curr.isSelected = true

    }
    @IBAction func rbCheck(_ sender: DLRadioButton) {
        if sender.tag == 1 {
            manualRB.iconColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 100)
            autoRB.iconColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 100)
            //save status locally
            UserDefaults.standard.set("AUTO", forKey: "RBSTATUS")
        }
        else if sender.tag == 2 {
            autoRB.iconColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 100)
            manualRB.iconColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 100)
            UserDefaults.standard.set("MANUAL", forKey: "RBSTATUS")

        }
        else{
            print("uncaught case")
        }
    }
    func readSetpoints(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 1036, completion: { (success, response) in
            guard success == true else {
                return
            }
        })
    }
    override func viewDidAppear(_ animated: Bool){
        if let x = UserDefaults.standard.object(forKey: "RBSTATUS") as? String{
            if x == "MANUAL"{
                setActive(curr: manualRB)
            }
        }
        else{
            setActive(curr: autoRB)
        }
        //for some reason, doesn't set icon color in setActive...
        if autoRB.isSelected {
            autoRB.iconColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 100)
        }
    }
    override func viewWillAppear(_ animated: Bool){
        //start by making/fixing/starting over for this declaration...?
        textViewTester.text = "hello"
        
        if CENTRAL_SYSTEM == nil{ //this doesn't overwrite locally stored variable. Delete the app!
            //so if you're playing with Central System, delete and reinstall.
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        readSetPoints()
        //Add notification observer to get system stat
        /*NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)*/
    }
    
    private func readSetPoints(){
        var init316 = 650.0
//works
        CENTRAL_SYSTEM?.readRealRegister(register: 316, length: 2, completion: { (success, response) in
            self.textViewTester.text = "readRealRegister: "
            self.textViewTester.insertText("\(response)\n")
            init316 = Double(response) ?? 650.0
           
        })
//write/read bit works for 310. not 1036... but that's ok?
        
        self.textViewTester.insertText("...*read/writebit...")
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 310, completion: { (success, response) in
            self.textViewTester.insertText("readBits310: ")
            self.textViewTester.insertText("\(response![0]) ") //1
            guard success == true else {
                return
            }
        })
        
        CENTRAL_SYSTEM?.writeBit(bit: 310, value: 0)
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 310, completion: { (success, response) in
            self.textViewTester.insertText("\(response![0]) ")
            
            guard success == true else {
                return
            }
        })
        //second attempt to get this value. If fail, it's definitely not writing...
        
        CENTRAL_SYSTEM?.writeBit(bit: 310, value: 1)
        // **** readRegister yielded correct value, readBits did not.
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 310, completion: { (success, response) in
            self.textViewTester.insertText("\(response![0]) \n")
            
            guard success == true else {
                return
            }
        })
        
        
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 312, completion: { (success, response) in
            //self.textViewTester.insertText("L")
            self.textViewTester.insertText("readBits312: ")
            self.textViewTester.insertText("\(response![0])\n")
            
            guard success == true else {
                return
            }
            
        })
 /*
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5040), completion: { (success, response) in
            guard success == true else { return }
            self.textViewTester.insertText("readRegister5040: ")
            let value = Int(truncating: response![0] as! NSNumber)
            self.textViewTester.insertText("\(value)\n")
        })
        
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5045), completion: { (success, response) in
            guard success == true else { return }
            self.textViewTester.insertText("readRegister5045: ")
            let value = Int(truncating: response![0] as! NSNumber)
            self.textViewTester.insertText("\(value)\n")
        })*/
        self.textViewTester.insertText("...Read/**writeReg :( ... \n")
        let initValue5000 = 0 //dummy val
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5002), completion: { (success, response) in
            guard success == true else { return }
            self.textViewTester.insertText("initval 5002: ")
            let value = Int(truncating: response![0] as! NSNumber)
            self.textViewTester.insertText("\(value)\n")
        })
        CENTRAL_SYSTEM!.writeRegister(register: 5002, value: 1)
        CENTRAL_SYSTEM!.readRegister(length: 1, startingRegister: Int32(5002), completion: { (success, response) in
            guard success == true else { return }
            self.textViewTester.insertText("Exp r5002=\'1\': ")
            let value = Int(truncating: response![0] as! NSNumber)
            self.textViewTester.insertText("\(value)\n")
        })
        CENTRAL_SYSTEM!.writeRegister(register: 5002, value: Int(initValue5000))
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5002), completion: { (success, response) in
            guard success == true else { return }
            self.textViewTester.insertText("Exp r5002=0 again?: ")
            let value = Int(truncating: response![0] as! NSNumber)
            self.textViewTester.insertText("\(value)\n")
        })
        
        self.textViewTester.insertText("...readReadReg/writeRealReg...")
        CENTRAL_SYSTEM?.writeRealValue(register: 316, value: Float(0.555))
        CENTRAL_SYSTEM?.readRealRegister(register: 316, length: 2, completion: { (success, response) in
            self.textViewTester.insertText("after W (0.555): ")
            self.textViewTester.insertText("\(response)\n")
        })
        CENTRAL_SYSTEM?.writeRealValue(register: 316, value: Float(init316))
        CENTRAL_SYSTEM?.readRealRegister(register: 316, length: 2, completion: { (success, response) in
            self.textViewTester.insertText("after W (650.0): ")
            self.textViewTester.insertText("\(response)\n")
        })

        
        /*
        CENTRAL_SYSTEM?.readRealRegister(register: 600, length: 2, completion: { (success, response) in
            
            //self.orpSetpointTarget.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 318, length: 2, completion: { (success, response) in
            
            //self.orpSetpointHigh.text   = "\(response)"
        })*/
        
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
