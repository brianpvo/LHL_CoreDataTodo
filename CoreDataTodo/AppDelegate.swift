//
//  AppDelegate.swift
//  CoreDataTodo
//
//  Created by Brian Vo on 2018-05-16.
//  Copyright © 2018 Brian Vo. All rights reserved.
//

import UIKit
import CoreData
import SAMKeychain

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var username: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.persistentContainer.viewContext
        
        let defaults = UserDefaults.standard
        let hasRegistered = defaults.bool(forKey: "username_registered")
        defaults.set("Enter a title", forKey: "title")
        defaults.set("Enter a description", forKey: "todoDescription")
        defaults.set("Enter a priority value", forKey: "priorityNumber")
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = (self.window?.rootViewController?.view.bounds)!
        
        if !hasRegistered {
            signUp(blurVisualEffectView: blurVisualEffectView)
        }
        else {
            login(loginDescription: "Enter username and password", blurVisualEffectView: blurVisualEffectView)
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreDataTodo")
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
    
    func signUp(blurVisualEffectView: UIVisualEffectView) {
        let signUpAlert = UIAlertController(title: "Sign Up", message: "Enter username and password", preferredStyle: .alert)
        
        signUpAlert.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        signUpAlert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        let signUpAction = UIAlertAction(title: "Sign Up", style: .default) { (action) in
            if let usernameTextField = signUpAlert.textFields?[0], let usernameText = usernameTextField.text {
                self.username = usernameText
            }
            if let passwordTextField = signUpAlert.textFields?[1], let passwordText = passwordTextField.text {
                guard let username = self.username else { return }
                SAMKeychain.setPassword(passwordText, forService: "CoreDataTodo", account: username)
                UserDefaults.standard.set(true, forKey: "username_registered")
            }
            
            blurVisualEffectView.removeFromSuperview()
        }
        
        signUpAlert.addAction(signUpAction)
        DispatchQueue.main.async {
            self.window?.rootViewController?.view.addSubview(blurVisualEffectView)
            self.window?.rootViewController?.present(signUpAlert, animated: true, completion: nil)
        }
    }
    
    func login(loginDescription: String, blurVisualEffectView: UIVisualEffectView) {
        let loginAlert = UIAlertController(title: "Login", message: loginDescription, preferredStyle: .alert)
        
        loginAlert.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        loginAlert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { (action) in
            if let usernameTextField = loginAlert.textFields?[0], let usernameText = usernameTextField.text, let passwordTextField = loginAlert.textFields?[1], let passwordText = passwordTextField.text {
                
                let retrievePass = SAMKeychain.password(forService: "CoreDataTodo", account: usernameText, error: nil)
                
                if passwordText == retrievePass {
                    blurVisualEffectView.removeFromSuperview()
                }
                else {
                    self.login(loginDescription: "Wrong username/password. Try Again.", blurVisualEffectView: blurVisualEffectView)
                }
            }
        }
        
        loginAlert.addAction(loginAction)
        DispatchQueue.main.async {
            self.window?.rootViewController?.view.addSubview(blurVisualEffectView)
            self.window?.rootViewController?.present(loginAlert, animated: true, completion: nil)
        }
    }
    
}

