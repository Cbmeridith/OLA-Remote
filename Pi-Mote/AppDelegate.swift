//
//  AppDelegate.swift
//  Pi-Mote
//
//  Created by Cody Meridith on 10/24/16.
//  Copyright © 2016 Cody Meridith. All rights reserved.
//

import UIKit

let pi = PiStream()
var pathToSettings: String!
var settings: NSMutableDictionary!

enum ShortcutIdentifier: String {
    case LightsOn
    case LightsOff

    init?(identifier: String) {
        guard let shortIdentifier = identifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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

    
    // MARK: Shortcut Handler Methods
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(shouldPerformActionFor(shortcutItem: shortcutItem))
    }
    
    private func shouldPerformActionFor(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        //print(shortcutType)
        guard let shortcutIdentifier = ShortcutIdentifier(identifier: shortcutType) else {
            return false
        }
        return preformActionFor(shortcutIdentifier: shortcutIdentifier)
    }
    
    private func preformActionFor(shortcutIdentifier: ShortcutIdentifier) -> Bool {
        //print(shortcutIdentifier)
        
        let settingsDestPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let settingsFullDestPath = NSURL(fileURLWithPath: settingsDestPath).appendingPathComponent("Settings.plist")
        let settingsFullDestPathString = settingsFullDestPath?.path
        pathToSettings = settingsFullDestPathString
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        
        //load things from plists
        pi.IP = settings?.value(forKey: "Address") as? String
        pi.openConnection()
        
        switch shortcutIdentifier {
            case .LightsOn:
                print("AllOn sent from lock screen")
                pi.sendCode(code: "ALLON", length: 5)
                pi.closeConnection()
                return true
            case .LightsOff:
                print("AllOff sent from lock screen")
                pi.sendCode(code: "ALLOFF", length: 6)
                pi.closeConnection()
                return true
        }
    }

}

