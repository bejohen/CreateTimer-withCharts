//
//  Activity+CoreDataProperties.swift
//  
//
//  Created by Johanes Steven on 15/07/19.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var estimatedTime: String?
    @NSManaged public var reason: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var spendTime: String?
    @NSManaged public var isCancelled: Bool

}
