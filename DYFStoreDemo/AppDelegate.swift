//
//  AppDelegate.swift
//
//  Created by dyf on 2016/11/28. ( https://github.com/dgynfi/DYFStore )
//  Copyright © 2016 dyf. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DYFStoreAppStorePaymentDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.displayStartupPage()
        
        // Wether to allow the logs output to console.
        DYFStore.default.enableLog = true
        
        // Adds an observer that responds to updated transactions to the payment queue.
        // If an application quits when transactions are still being processed, those transactions are not lost. The next time the application launches, the payment queue will resume processing the transactions. Your application should always expect to be notified of completed transactions.
        // If more than one transaction observer is attached to the payment queue, no guarantees are made as to the order they will be called in. It is recommended that you use a single observer to process and finish the transaction.
        DYFStore.default.addPaymentTransactionObserver()
        
        // Sets the delegate processes the purchase which was initiated by user from the App Store.
        DYFStore.default.delegate = self
        
        DYFStore.default.keychainPersister = DYFStoreKeychainPersistence()
        
        return true
    }
    
    func displayStartupPage() {
        Thread.sleep(forTimeInterval: 2.0)
    }
    
    // Processes the purchase which was initiated by user from the App Store.
    func didReceiveAppStorePurchaseRequest(_ queue: SKPaymentQueue, payment: SKPayment, forProduct product: SKProduct) {
        
        if !DYFStore.canMakePayments() {
            self.showTipsMessage("Your device is not able or allowed to make payments!")
            return
        }
        
        // Get account name from your own user system.
        let accountName = "Handsome Jon"
        
        // This algorithm is negotiated with server developer.
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        
        DYFStoreManager.shared.addPayment(product.productIdentifier, userIdentifier: userIdentifier)
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
    
}
