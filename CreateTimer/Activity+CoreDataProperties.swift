//
//  Activity+CoreDataProperties.swift
//  CreateTimer
//
//  Created by Johanes Steven on 03/07/19.
//  Copyright © 2019 bejohen. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: Int32
    @NSManaged public var date: NSDate?
    @NSManaged public var startTime: String?
    @NSManaged public var finishTime: String?
    @NSManaged public var estimatedTime: String?

}
