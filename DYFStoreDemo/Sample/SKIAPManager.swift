//
//  SKIAPManager.swift
//
//  Created by Tenfay on 2016/11/28.
//  Copyright © 2016 Tenfay. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import DYFStoreReceiptVerifier_Swift

open class SKIAPManager: NSObject, DYFStoreReceiptVerifierDelegate {
    
    /// The property contains the purchase information.
    private var purchaseInfo: DYFStore.NotificationInfo!
    /// The property contains the download information.
    private var downloadInfo: DYFStore.NotificationInfo!
    
    /// Creates and returns a receipt verifier by using lazy loading.
    private lazy var receiptVerifier: DYFStoreReceiptVerifier = {
        let verifier = DYFStoreReceiptVerifier()
        verifier.delegate = self
        return verifier
    }()
    
    /// Returns a store manager singleton.
    public static let shared = SKIAPManager()
    
    /// Overrides default constructor.
    public override init() {
        super.init()
        //self.addStoreObserver()
    }
    
    /// deinit
    deinit {
        //self.removeStoreObserver()
    }
    
    /// Make sure the class has only one instance.
    open override func copy() -> Any {
        return self
    }
    
    /// Make sure the class has only one instance.
    open override func mutableCopy() -> Any {
        return self
    }
    
    /// Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.
    ///
    /// - Parameters:
    ///   - productIdentifier: A given product identifier.
    ///   - userIdentifier: An opaque identifier for the user’s account on your system.
    public func addPayment(_ productIdentifier: String?, userIdentifier: String? = nil) {
        self.sk_showLoading("Waiting...") // Initiate purchase request.
        DYFStore.default.purchaseProduct(productIdentifier, userIdentifier: userIdentifier)
    }
    
    /// Requests to restore previously completed purchases with an opaque identifier for the user’s account on your system.
    ///
    /// - Parameter userIdentifier: An opaque identifier for the user’s account on your system.
    public func restorePurchases(_ userIdentifier: String? = nil) {
        DYFStoreLog("userIdentifier: \(userIdentifier ?? "")")
        self.sk_showLoading("Restoring...")
        DYFStore.default.restoreTransactions(userIdentifier: userIdentifier)
    }
    
    func addStoreObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(processPurchaseNotification(_:)), name: DYFStore.purchasedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processDownloadNotification(_:)), name: DYFStore.downloadedNotification, object: nil)
    }
    
    func removeStoreObserver() {
        NotificationCenter.default.removeObserver(self, name: DYFStore.purchasedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: DYFStore.downloadedNotification, object: nil)
    }
    
    @objc private func processPurchaseNotification(_ notification: Notification) {
        self.sk_hideLoading()
        self.purchaseInfo = (notification.object as! DYFStore.NotificationInfo)
        switch self.purchaseInfo.state! {
        case .purchasing:
            self.sk_showLoading("Purchasing...")
            break
        case .cancelled:
            self.sendNotice("You cancel the purchase")
            break
        case .failed:
            self.sendNotice(String(format: "An error occurred, \(self.purchaseInfo.error!.code)"))
            break
        case .succeeded, .restored:
            self.completePayment()
            break
        case .restoreFailed:
            self.sendNotice(String(format: "An error occurred, \(self.purchaseInfo.error!.code)"))
            break
        case .deferred:
            DYFStoreLog("Deferred")
            break
        }
    }
    
    @objc private func processDownloadNotification(_ notification: Notification) {
        self.downloadInfo = (notification.object as! DYFStore.NotificationInfo)
        switch self.downloadInfo.downloadState! {
        case .started:
            DYFStoreLog("The download started")
            break
        case .inProgress:
            DYFStoreLog("The download progress: \(self.downloadInfo.downloadProgress)%%")
            break
        case .cancelled:
            DYFStoreLog("The download cancelled")
            break
        case .failed:
            DYFStoreLog("The download failed")
            break
        case .succeeded:
            DYFStoreLog("The download succeeded: 100%%")
            break
        }
    }
    
    private func completePayment() {
        let info = self.purchaseInfo!
        let persister = DYFStoreUserDefaultsPersistence()
        
        let identifier = info.transactionIdentifier!
        if !persister.containsTransaction(identifier) {
            self.storeReceipt()
            return
        }
        
        if let tx = persister.retrieveTransaction(identifier) {
            DYFStoreLog("tx.state: \(tx.state)")
            DYFStoreLog("tx.productIdentifier: \(tx.productIdentifier!)")
            DYFStoreLog("tx.userIdentifier: \(tx.userIdentifier ?? "null")")
            DYFStoreLog("tx.transactionIdentifier: \(tx.transactionIdentifier!)")
            DYFStoreLog("tx.transactionTimestamp: \(tx.transactionTimestamp!)")
            DYFStoreLog("tx.originalTransactionIdentifier: \(tx.originalTransactionIdentifier ?? "null")")
            DYFStoreLog("tx.originalTransactionTimestamp: \(tx.originalTransactionTimestamp ?? "null")")
            if let receiptData = tx.transactionReceipt!.base64DecodedData() {
                DYFStoreLog("tx.transactionReceipt: \(receiptData)")
                self.verifyReceipt(receiptData)
            }
        }
    }
    
    private func storeReceipt() {
        DYFStoreLog()
        guard let url = DYFStore.receiptURL() else {
            self.refreshReceipt()
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let info = self.purchaseInfo!
            let persister = DYFStoreUserDefaultsPersistence()
            
            let tx = DYFStoreTransaction()
            if info.state! == .succeeded {
                tx.state = DYFStoreTransactionState.purchased.rawValue
            } else if info.state! == .restored {
                tx.state = DYFStoreTransactionState.restored.rawValue
            }
            
            tx.productIdentifier = info.productIdentifier
            tx.userIdentifier = info.userIdentifier
            tx.transactionTimestamp = info.transactionDate?.timestamp()
            tx.transactionIdentifier = info.transactionIdentifier
            tx.originalTransactionTimestamp = info.originalTransactionDate?.timestamp()
            tx.originalTransactionIdentifier = info.originalTransactionIdentifier
            
            tx.transactionReceipt = data.base64EncodedString()
            persister.storeTransaction(tx)
            
            self.verifyReceipt(data)
        } catch let error {
            DYFStoreLog("error: \(error.localizedDescription)")
            self.refreshReceipt()
            return
        }
    }
    
    private func refreshReceipt() {
        DYFStoreLog()
        self.sk_showLoading("Refresh receipt...")
        DYFStore.default.refreshReceipt(onSuccess: {
            self.storeReceipt()
        }) { (error) in
            self.failToRefreshReceipt()
        }
    }
    
    private func failToRefreshReceipt() {
        DYFStoreLog()
        self.sk_hideLoading()
        self.sk_showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                          message: "Fail to refresh receipt! Please check if your device can access the internet.",
                          cancelButtonTitle: "Cancel",
                          cancel: { (cancelAction) in },
                          confirmButtonTitle: NSLocalizedString("Retry", tableName: nil, comment: ""))
        { (action) in
            self.refreshReceipt()
        }
    }
    
    // It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C).
    // If the receipts are verified by your own server, the client needs to upload these parameters, such as: "transaction identifier, bundle identifier, product identifier, user identifier, shared sceret(Subscription), receipt(Safe URL Base64), original transaction identifier(Optional), original transaction time(Optional) and the device information, etc.".
    private func verifyReceipt(_ receiptData: Data?) {
        DYFStoreLog()
        self.sk_hideLoading()
        self.sk_showLoading("Verify receipt...")
        
        var data: Data!
        if let tempData = receiptData {
            data = tempData
        } else {
            if let url = DYFStore.receiptURL() {
                do {
                    data = try Data(contentsOf: url)
                } catch let error {
                    DYFStoreLog("error: \(error.localizedDescription)")
                    self.failToRefreshReceipt()
                    return
                }
            }
        }
        DYFStoreLog("data: \(data!)")
        
        self.receiptVerifier.verifyReceipt(data)
        // Only used for receipts that contain auto-renewable subscriptions.
        //self.receiptVerifier.verifyReceipt(data, sharedSecret: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
    }
    
    private func retryToVerifyReceipt() {
        let info = self.purchaseInfo!
        let persister = DYFStoreUserDefaultsPersistence()
        
        let identifier = info.transactionIdentifier!
        let transaction = persister.retrieveTransaction(identifier)
        if let tx = transaction, let receiptData = tx.transactionReceipt!.base64DecodedData() {
            self.verifyReceipt(receiptData)
        }
    }
    
    private func sendNotice(_ message: String) {
        self.sk_showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                          message: message,
                          cancelButtonTitle: nil,
                          cancel: nil,
                          confirmButtonTitle: NSLocalizedString("I see!", tableName: nil, comment: ""))
        { (action) in
            DYFStoreLog("alert action title: \(action.title!)")
        }
    }
    
    // MARK: - DYFStoreReceiptVerifierDelegate
    
    public func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any]) {
        DYFStoreLog("data: \(data)")
        self.sk_hideLoading()
        self.sk_showTipsMessage("Purchase Successfully")
        
        DispatchQueue.main.asyncAfter(delay: 1.2) {
            let info = self.purchaseInfo!
            let store = DYFStore.default
            let persister = DYFStoreUserDefaultsPersistence()
            let identifier = info.transactionIdentifier!
            
            if info.state! == .restored {
                let tx = store.extractRestoredTransaction(identifier)
                store.finishTransaction(tx)
            } else {
                let tx = store.extractPurchasedTransaction(identifier)
                // The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.
                store.finishTransaction(tx)
            }
            
            persister.removeTransaction(identifier)
            
            if let id = info.originalTransactionIdentifier {
                persister.removeTransaction(id)
            }
        }
    }
    
    public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {
        // Prints the reason of the error.
        DYFStoreLog("error: \(error.code), \(error.localizedDescription)")
        self.sk_hideLoading()
        
        // An error occurs that has nothing to do with in-app purchase. Maybe it's the internet.
        if error.code < 21000 {
            // After several attempts, you can cancel refreshing receipt.
            self.sk_showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                              message: "Fail to verify receipt! Please check if your device can access the internet.",
                              cancelButtonTitle: "Cancel",
                              cancel: nil,
                              confirmButtonTitle: NSLocalizedString("Retry", tableName: nil, comment: ""))
            { (action) in
                DYFStoreLog("alert action title: \(action.title!)")
                self.verifyReceipt(nil)
            }
            return
        }
        
        self.sk_showTipsMessage("Fail to purchase product!")
        
        DispatchQueue.main.asyncAfter(delay: 1.2) {
            let info = self.purchaseInfo!
            let store = DYFStore.default
            let persister = DYFStoreUserDefaultsPersistence()
            let identifier = info.transactionIdentifier!
            
            if info.state! == .restored {
                let tx = store.extractRestoredTransaction(identifier)
                store.finishTransaction(tx)
            } else {
                let tx = store.extractPurchasedTransaction(identifier)
                // The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.
                store.finishTransaction(tx)
            }
            
            persister.removeTransaction(identifier)
            
            if let id = info.originalTransactionIdentifier {
                persister.removeTransaction(id)
            }
        }
    }
    
}
