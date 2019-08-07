//
//  View2Controller.swift
//  WETSkidmeter4
//
//  Created by Bethany Chen on 8/2/19.
//  Copyright © 2019 Bethany Chen. All rights reserved.
//

import UIKit

public var CENTRAL_SYSTEM: CentralSystem?
class View2Controller: UIPageViewController {

    

    //TODO: first just READ from registers.
    @IBOutlet weak var textViewTester: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//start of my own code... good luck
        //start by making/fixing/starting over for this declaration...?
       /*var objLibModbus = [[ObjectiveLibModbus alloc] initWithTCP:@"192.168.2.10" port:502 device:1];
        */
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
