//
//  DataStorage.swift
//  waterTime
//
//  Created by Клоун on 14.09.2022.
//

import Foundation
import CoreData

class DataStorage {
    static let shared = DataStorage()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "waterTime")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    init() {}
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveData(goal: String, drank: String, result: Int) {
        let entity = Water(context: persistentContainer.viewContext)
        entity.goalToDrink = goal
        entity.drank = drank
        entity.result = Int64(result)
        
        do {
            try persistentContainer.viewContext.save()
        } catch  {
            print("Something got wrong")
        }
    }
    
    func loadFromCoreData(completion: (NSManagedObject) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Water")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            
            for result in result as! [NSManagedObject] {
                completion(result)
            }
        } catch {
            print("Fail")
        }
    }
    
    func deleteAllData() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Water")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
        } catch {
            print ("Here was an error")
        }
    }
}
