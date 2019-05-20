//
//  Show+CoreDataProperties.swift
//  iPadControls
//
//  Created by Arpi Derm on 1/30/17.
//  Copyright © 2017 WET. All rights reserved.
//

import Foundation
import CoreData


extension Show {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Show>{
        return NSFetchRequest<Show>(entityName: "Show");
    }

    @NSManaged public var number: Int16
    @NSManaged public var name: String?
    @NSManaged public var duration: Int32

}
