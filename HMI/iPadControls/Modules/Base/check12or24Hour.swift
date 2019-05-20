//
//  check12or24Hour.swift
//  iPadControls
//
//  Created by Jan Manalo on 8/6/18.
//  Copyright © 2018 WET. All rights reserved.
//


import Foundation

extension UIViewController {
  
    func checkHourSetting(){
        if let formatString: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current) {
            let checker24hrs = formatString.contains("H")
            let checker24hrs2 = formatString.contains("k")
            
            if checker24hrs || checker24hrs2 {
                is24hours = true
            } else {
                is24hours = false
            }
        } else {
            is24hours = true
        }
    }
}
