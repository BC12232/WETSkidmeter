//
//  PumpDetail+CoreDataProperties.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/27/17.
//  Copyright © 2017 WET. All rights reserved.
//
//

import Foundation
import CoreData


extension PumpDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PumpDetail> {
        return NSFetchRequest<PumpDetail>(entityName: "PumpDetail")
    }

    @NSManaged public var aboveHighSP: Double
    @NSManaged public var belowLLLSP: Double
    @NSManaged public var belowLLSP: Double
    @NSManaged public var belowLSP: Double
    @NSManaged public var currentMax: Double
    @NSManaged public var maxFrequency: Double
    @NSManaged public var pumpNumber: Double
    @NSManaged public var scaleMaxSP: Double
    @NSManaged public var scaleMinSP: Double
    @NSManaged public var temperatureMax: Double
    @NSManaged public var temperatureMid: Double
    @NSManaged public var voltageMax: Double
    @NSManaged public var voltageMin: Double

}
