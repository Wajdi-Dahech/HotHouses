//
//  AppDelegate.swift
//  HotHouses
//
//  Created by Wajdi on 6/26/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let locationService = LocationService()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    // Redirect User to proper interface based on Location service Status
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


           locationService.didChangeStatus = { [weak self] success in
               if success {
                   self?.locationService.getLocation()
               }
               
     }
          locationService.newLocation = { [weak self] result in
               switch result {
               case .success( _) :
                self!.navigation ()
               case .failure( _) :
                self!.navigation ()
              }
           }
        switch locationService.status {
        case .notDetermined:
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
            locationViewController?.delegate = self
            window!.rootViewController = locationViewController
       
        case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
            navigation ()
        default:
            self.navigation ()
            locationService.getLocation()
        }
        window!.makeKeyAndVisible()
        // Override point for customization after application launch.
        return true
    }


    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "HotHouses")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func navigation (){
        let tabBar = self.storyboard.instantiateViewController(withIdentifier: "ID")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = tabBar
    }

}

extension AppDelegate: LocationActions{
    func didTapAllow() {
        locationService.requestLocationAuthorization()
    }
    func didTapDeny(){
        navigation()
    }
}
