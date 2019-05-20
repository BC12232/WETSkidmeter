    //
    //  AppDelegate.swift
    //  iPadControls
    //
    //  Created by Arpi Derm on 11/30/16.
    //  Copyright © 2016 WET. All rights reserved.
    //
    
    import UIKit
    import CoreData
    
    @available(iOS 10.0, *)
    @UIApplicationMain
    
    class AppDelegate: UIResponder, UIApplicationDelegate{
        
        var window: UIWindow?
        
        private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool{
            
            return true
            
        }
        
        func applicationWillResignActive(_ application: UIApplication){
            
        }
        
        func applicationDidEnterBackground(_ application: UIApplication){
            
        }
        
        func applicationWillEnterForeground(_ application: UIApplication){
            
        }
        
        func applicationDidBecomeActive(_ application: UIApplication){
            
        }
        
        func applicationWillTerminate(_ application: UIApplication){
            setUDForConnection = false
            self.saveContext()
        }
        
        //MARK: - Core Data stack
        
        @available(iOS 10.0, *)
        
        lazy var persistentContainer: NSPersistentContainer = {
            
            let container = NSPersistentContainer(name: "iPadControls")
            
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                
                if let error = error as NSError?{
                    
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                    
                }
            })
            
            return container
        }()
        
        //MARK: - Core Data Saving support
        
        func saveContext(){
            
            let context = persistentContainer.viewContext
            
            if context.hasChanges{
                
                do{
                    
                    try context.save()
                    
                }catch{
                    
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    
                }
            }
        }
        
    }
    
