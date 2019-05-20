//
//  Pump+CoreDataProperties.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/27/17.
//  Copyright © 2017 WET. All rights reserved.
//
//

import Foundation
import CoreData


extension Pump {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pump> {
        return NSFetchRequest<Pump>(entityName: "Pump")
    }

    @NSManaged public var maxPumpFrequency: Int16
    @NSManaged public var outOfRangeMessage: String?
    @NSManaged public var screenName: String?

}
