//
//  AppDelegate.swift
//  Showcase
//
//  Created by Haru Myunghoon Lee on 9/11/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FBSDKLoginKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // connect to Firebase
        FirebaseApp.configure()
        
        // Grab user's current email
        let curUser = Auth.auth().currentUser
        var curEmail = ""
        if let user = curUser {
            curEmail = user.email!
            // Access the storyboard and fetch an instance of the view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: RootViewController = storyboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController;

            // Then push that view controller onto the navigation stack
            let rootViewController = self.window!.rootViewController as! UINavigationController;
            rootViewController.pushViewController(viewController, animated: true);
        }
        
        // Set the keyboard to use IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        
        // Navigation controller background color
        UINavigationBar.appearance().barTintColor = UIColor(red:0.33, green:0.84, blue:0.75, alpha:1.0)

        // Navigation controller text color for "back" button
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // Navigation controller text color for title
        
        // Facebook stuff
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

