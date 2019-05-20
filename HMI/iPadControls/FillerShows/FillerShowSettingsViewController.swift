//
//  FillerShowSettingsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/14/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit


class FillerShowSettingsViewController: UIViewController, UIPopoverControllerDelegate{
   
    
    var controller: ACTDesignateTestShowViewController?
    var dismissPopoverTimer:      Timer?
    var dismiss: Int = 0
    var popoverDesignateTestShow: UIPopoverController?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    @IBAction func designateFillerShowPopover(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "fillerShows", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "designateFiller") as! DesignateFillerShowViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 600, height: 500)
        popover?.sourceRect = CGRect(x: -500, y: 70, width: 600, height: 500)
        popover?.sourceView = sender
        popoverContent.fillerSpecialNum = sender.tag
        self.present(nav, animated: true, completion: nil)

    }
    
    @objc func dismissPopoverView() {
        
        let defaults = UserDefaults.standard
        dismiss = (defaults.object(forKey: "dismissTestShows") as? NSNumber)?.intValue ?? 0
        
        if dismiss == 1 {
            
            dismissPopoverTimer!.invalidate()
            dismissPopoverTimer = nil
            
            popoverDesignateTestShow!.dismiss(animated: true)
            defaults.set("0", forKey: "dismissTestShows")
        }
    }
}
