//
//  IntrusionError+CoreDataProperties.swift
//  iPadControls
//
//  Created by Arpi Derm on 3/23/17.
//  Copyright © 2017 WET. All rights reserved.
//

import Foundation
import CoreData


extension IntrusionError{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IntrusionError>{
        return NSFetchRequest<IntrusionError>(entityName: "IntrusionError");
    }

    @NSManaged public var errorCode: Int16
    @NSManaged public var detail: String?
    @NSManaged public var timeStamp: NSDate?

}
