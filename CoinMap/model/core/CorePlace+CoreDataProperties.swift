//
//  CorePlace+CoreDataProperties.swift
//  CoinMap
//
//  Created by Lex Leontiev on 26/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//
//

import Foundation
import CoreData


extension CorePlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CorePlace> {
        return NSFetchRequest<CorePlace>(entityName: "CorePlace")
    }

    @NSManaged public var placeId: Int64
    @NSManaged public var placeName: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var desc: String?

}
