//
//  ProjectorStatusViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 5/14/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class ProjectorStatusViewController: UIViewController {

    @IBOutlet weak var prjName: UILabel!
    @IBOutlet weak var connectionStatus: UIImageView!
    @IBOutlet weak var powerStatusLbl: UILabel!
    @IBOutlet weak var shutterStatus: UILabel!
    @IBOutlet weak var temp_IntakeValue: UILabel!
    @IBOutlet weak var temp_mainBoardValue: UILabel!
    @IBOutlet weak var temp_heatSinkValue: UILabel!
    
    var projectorStats = PROJECTOR_STATS()
    
    var prjNumber = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        readProjectorStats()
        // Do any additional setup after loading the view.
    }
    
    func readProjectorStats (){
        if self.projectorStats.connectionStat == "Connected" {
            self.connectionStatus.image = #imageLiteral(resourceName: "green")
        } else {
             self.connectionStatus.image = #imageLiteral(resourceName: "red")
        }
        self.prjName.text = self.projectorStats.projName
        self.powerStatusLbl.text = self.projectorStats.powerStat
        self.shutterStatus.text = self.projectorStats.shutterStat
    }
}
