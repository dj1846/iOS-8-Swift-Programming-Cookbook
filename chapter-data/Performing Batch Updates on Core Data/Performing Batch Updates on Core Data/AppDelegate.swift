//
//  AppDelegate.swift
//  Performing Batch Updates on Core Data
//
//  Created by vandad on 167//14.
//  Copyright (c) 2014 Pixolity Ltd. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let entityName = NSStringFromClass(Person.classForCoder())
  
  func populateDatabase(){
    
    for counter in 0..<1000{
      
      let person = NSEntityDescription.insertNewObjectForEntityForName(
        entityName,
        inManagedObjectContext: managedObjectContext) as! Person
      
      person.firstName = "First name \(counter)"
      person.lastName = "Last name \(counter)"
      person.age = NSNumber(unsignedInt: arc4random_uniform(120))
      
    }
    
    
    do{
      try managedObjectContext.save()
      print("Managed to populate the database")
    } catch let error as NSError{
      print("Failed to populate the database. Error = \(error)")
    }
    
  }

  func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

      let batch = NSBatchUpdateRequest(entityName: entityName)
      batch.propertiesToUpdate = ["age" : 18]
      batch.predicate = NSPredicate(format: "age < %@", 18 as NSNumber)
      batch.resultType = .UpdatedObjectsCountResultType
      
      
      do{
        let result = try managedObjectContext.executeRequest(batch)
        if let theResult = result as? NSBatchUpdateResult{
          if let numberOfAffectedPersons = theResult.result as? Int{
            print("Number of people who were previously younger than " +
              "18 years old and whose age is now set to " +
              "18 is \(numberOfAffectedPersons)")
          }
        }
      } catch let error as NSError{
        print("Could not perform batch request. Error = \(error)")
      }
      
      return true
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // #pragma mark - Core Data stack
  
  lazy var applicationDocumentsDirectory: NSURL = {
      // The directory the application uses to store the Core Data store file. This code uses a directory named "com.pixolity.ios.coredata" in the application's documents Application Support directory.
      let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
      return urls[urls.count-1] as NSURL
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
      // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
      let modelURL = NSBundle.mainBundle().URLForResource("Performing_Batch_Updates_on_Core_Data", withExtension: "momd")!
      return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    
    return coordinator
    }()

  lazy var managedObjectContext: NSManagedObjectContext = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
  
}

