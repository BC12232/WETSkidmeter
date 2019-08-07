//
//  ViewController.swift
//  WETSkidmeter4
//
//  Created by Bethany Chen on 7/31/19.
//  Copyright © 2019 Bethany Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textfield1: UITextField!
    @IBOutlet weak var textfield2: UITextField!
    @IBOutlet weak var textfield3: UITextField!
    
    @IBOutlet weak var orpOutput1: UITextView!
    @IBOutlet weak var orpOutput2: UITextView!
    @IBOutlet weak var orpOutput3: UITextView!
    
    //labels
    @IBOutlet weak var orpLabel: UITextView!
    @IBOutlet weak var phLabel: UITextView!
    @IBOutlet weak var condLabel: UITextView!
    //global to track
    @IBOutlet weak var mV: UITextView!
    @IBOutlet weak var uS: UITextView!
   
    //global to track
    var activeTextField = UITextField()
    
    //vars for conversion
    var sensorInputImpedance : Double = 113
    var orpV : Double = 1.005
    //hard-coded vars
    var phV : Double = 1 //TODO: calculate
    var phScalemA : Double = 16.0/140.0
    var tdsV : Double = 1.0
    
    var orpB5max : Double = 2000.0
    var orpB4min : Double = -1000.0
    var orpC4minMA : Double = 4
    var phC15minMA : Double = 4
    var B31 : Double = 100.0
    var tdsC26minMA : Double = 4
    
    //computed vars
    lazy var orpScaleMV : Double = sensorInputImpedance*orpScalemA/1000.0
    lazy var orpScalemA : Double = 16.0*1000.0/(orpB5max-orpB4min)
    lazy var orpMinV : Double = orpC4minMA*sensorInputImpedance/1000.0
    lazy var tdsScalemA : Double = 16.0/B31
    lazy var tdsScaleMV : Double = tdsScalemA*sensorInputImpedance
    lazy var tdsMinV : Double = tdsC26minMA/1000.0*sensorInputImpedance
    lazy var phScaleMV : Double = phScalemA*sensorInputImpedance
    lazy var phMinV : Double = phC15minMA*sensorInputImpedance/1000.0
    
    //TODO: try to implement real registers.
    //then read+write real vals.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textfield1.delegate = self
        textfield1.tag=1
        textfield2.delegate=self
        textfield2.tag=2
        textfield3.delegate=self
        textfield3.tag=3
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        
        
        
        textfield1.borderStyle=UITextField.BorderStyle.none
        textfield1.textColor=UIColor(red:117/255, green:117/255, blue:117/255, alpha:1)
        textfield2.borderStyle=UITextField.BorderStyle.none
        textfield2.textColor=UIColor(red:117/255, green:117/255, blue:117/255, alpha:1)
        textfield3.borderStyle=UITextField.BorderStyle.none
        textfield3.textColor=UIColor(red:117/255, green:117/255, blue:117/255, alpha:1)
        
        //stylize output fields + labels
        mV.textColor=UIColor(red:224/255, green:224/255, blue:224/255, alpha:1)
        uS.textColor=UIColor(red:224/255, green:224/255, blue:224/255, alpha:1)
        orpOutput1.textColor=UIColor(red:255/255, green:255/255, blue:255/255, alpha:1)
        orpOutput2.textColor=UIColor(red:255/255, green:255/255, blue:255/255, alpha:1)
        orpOutput3.textColor=UIColor(red:255/255, green:255/255, blue:255/255, alpha:1)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //my clear button
    @IBAction func clearAll(_ sender: UIButton) {
        textfield1.text = ""
        textfield2.text = ""
        textfield3.text = ""
        orpOutput1.text = "0.00"
        orpOutput2.text = "0.00"
        orpOutput3.text = "0"
    }
    //my textfield tracker
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //update contents of current activeTextField.
        calculate()
        print("didbeginediting entered.")
        activeTextField = textField
    }
    func calculate(){
        let textfieldDouble: Double? = Double(activeTextField.text!)
        //(orpV - orpMinV)/(orpScaleMV/1000.0) - 1000.0
        if self.activeTextField.tag == 1{
            orpV = textfieldDouble ?? 1.055
            if textfield1.text == "" || textfield1.text == "0" {
                orpOutput1.text = "0.00"
                return
            }
            let result = (orpV - orpMinV)/(orpScaleMV/1000.0) - 1000.0
            if result > 10000 {
                orpOutput1.text = "10000+"
            }else{
                orpOutput1.text = String(format:"%.2f", result)
            }
            return;
        }else if self.activeTextField.tag == 2{
            phV = textfieldDouble ?? 1.055
            if textfield2.text == "" || textfield2.text == "0" {
                orpOutput2.text = "0.00"
                return
            }
            let result = ((phV - phMinV)/(phScaleMV/100.0))
            if result > 10000 {
                orpOutput2.text = "10000+"
            }else{
                orpOutput2.text = String(format:"%.2f", result)
            }
            return;
        }
        else if self.activeTextField.tag == 3{
            tdsV = textfieldDouble ?? tdsScaleMV //TODO: find default
            if textfield3.text == "" || textfield3.text == "0" {
                orpOutput3.text = "0"
                return
            }
            
            let result = (tdsV - tdsMinV)/(tdsScaleMV/100000.0)
            print("\(tdsV)")
            print("\(tdsMinV)")
            print("\(tdsScaleMV)")
            print("\(result)")
            if result > 100000 {
                orpOutput3.text = "100000+"
            }else{
                orpOutput3.text = String(format:"%.0f", result)
            }
            return;
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //calculate and go.
        calculate()
        self.view.endEditing(true)
        
    }
}

