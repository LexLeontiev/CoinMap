//
//  CoreDataManager.swift
//  CoinMap
//
//  Created by Lex Leontiev on 25/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager: DataManagerProtocol {
   
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func savePlace(place: Place) {
        let corePlace: CorePlace
        corePlace = makeEntity()
        corePlace.placeId = Int64(place.id)
        corePlace.placeName = place.placeName
        corePlace.categoryName = place.categoryName
        corePlace.desc = place.desc
        try! context.save()
    }
    
    func removePlace(id: Int) {
        guard let corePlace = fetchBy(id: id) else {
            return
        }
        try! context.delete(corePlace)
        try! context.save()
    }
    
    func getPlace(id: Int) -> Place? {
        guard let corePlace = fetchBy(id: id) else {
            return nil
        }
        return Place(corePlace: corePlace)
    }
    
    fileprivate func fetchBy(id: Int) -> CorePlace? {
        let request = NSFetchRequest<CorePlace>(entityName: "CorePlace")
        request.predicate = NSPredicate(format: "placeId == %d", id)
        return try? context.fetch(request).first ?? makeEntity()
    }
    
    fileprivate func makeEntity() -> CorePlace {
        let description = NSEntityDescription.entity(forEntityName: "CorePlace", in: context)!
        return NSManagedObject(entity: description, insertInto: context) as! CorePlace
    }
    
}
