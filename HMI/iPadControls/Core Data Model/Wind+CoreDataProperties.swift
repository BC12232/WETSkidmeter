//
//  Wind+CoreDataProperties.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/26/17.
//  Copyright © 2017 WET. All rights reserved.
//
//

import Foundation
import CoreData


extension Wind {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wind> {
        return NSFetchRequest<Wind>(entityName: "Wind")
    }

    @NSManaged public var enableSetPoints: Bool
    @NSManaged public var metric: Bool
    @NSManaged public var numberOfWindSensors: Int16
    @NSManaged public var outOfRangeMessage: String?
    @NSManaged public var screenName: String?

}
