//
//  DYFStoreManager.swift
//
//  Created by dyf on 2016/11/28. ( https://github.com/dgynfi/DYFStore )
//  Copyright © 2016 dyf. All rights reserved.
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
import CommonCrypto

/// Custom method to calculate the SHA-256 hash using Common Crypto.
///
/// - Parameter s: A string to calculate hash.
/// - Returns: A SHA-256 hash value.
public func DYF_SHA256_HashValue(_ s: String) -> String? {
    
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH) // 32
    
    let cStr = s.cString(using: String.Encoding.utf8)!
    let cStrLen = Int(s.lengthOfBytes(using: String.Encoding.utf8))
    
    // Confirm that the length of C string is small enough
    // to be recast when calling the hash function.
    if cStrLen > UINT32_MAX {
        print("C string too long to hash: \(s)")
        return nil
    }
    
    let md = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
    
    CC_SHA256(cStr, CC_LONG(cStrLen), md)
    
    // Convert the array of bytes into a string showing its hex represention.
    let hash = NSMutableString()
    for i in 0..<digestLength {
        
        // Add a dash every four bytes, for readability.
        if i != 0 && i%4 == 0 {
            //hash.append("-")
        }
        hash.appendFormat("%02x", md[i])
    }
    
    md.deallocate()
    
    return hash as String
}

open class DYFStoreManager: NSObject, DYFStoreReceiptVerifierDelegate {
    
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
    
    /// A struct named "Static".
    private struct Static {
        static var instance: DYFStoreManager? = nil
    }
    
    /// Returns a store manager singleton.
    public class var shared: DYFStoreManager {
        
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard let instance = Static.instance else {
            let storeManager = DYFStoreManager()
            Static.instance = storeManager
            return storeManager
        }
        
        return instance
    }
    
    /// Overrides default constructor.
    public override init() {
        super.init()
        self.addStoreObserver()
    }
    
    /// deinit
    deinit {
        self.removeStoreObserver()
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
        self.showLoading("Waiting...") // Initiate purchase request.
        DYFStore.default.purchaseProduct(productIdentifier, userIdentifier: userIdentifier)
    }
    
    /// Requests to restore previously completed purchases with an opaque identifier for the user’s account on your system.
    ///
    /// - Parameter userIdentifier: An opaque identifier for the user’s account on your system.
    public func restorePurchases(_ userIdentifier: String? = nil) {
        DYFStoreLog("userIdentifier: \(userIdentifier ?? "")")
        self.showLoading("Restoring...")
        DYFStore.default.restoreTransactions(userIdentifier: userIdentifier)
    }
    
    private func addStoreObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processPurchaseNotification(_:)), name: DYFStore.purchasedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processDownloadNotification(_:)), name: DYFStore.downloadedNotification, object: nil)
    }
    
    private func removeStoreObserver() {
        NotificationCenter.default.removeObserver(self, name: DYFStore.purchasedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: DYFStore.downloadedNotification, object: nil)
    }
    
    @objc private func processPurchaseNotification(_ notification: Notification) {
        
        self.hideLoading()
        
        self.purchaseInfo = (notification.object as! DYFStore.NotificationInfo)
        
        switch self.purchaseInfo.state! {
        case .purchasing:
            self.showLoading("Purchasing...")
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
        let store = DYFStore.default
        let persister = store.keychainPersister!
        
        let identifier = info.transactionIdentifier!
        if !persister.containsTransaction(identifier) {
            self.storeReceipt()
            return
        }
        
        let transaction = persister.retrieveTransaction(identifier)
        if let tx = transaction {
            DYFStoreLog("transaction.state: \(tx.state)")
            DYFStoreLog("transaction.productIdentifier: \(tx.productIdentifier!)")
            DYFStoreLog("transaction.transactionIdentifier: \(tx.transactionIdentifier!)")
            DYFStoreLog("transaction.transactionTimestamp: \(tx.transactionTimestamp!)")
            
            if let receiptData = tx.transactionReceipt!.base64DecodedData() {
                DYFStoreLog("transaction.transactionReceipt: \(receiptData)")
                self.verifyReceipt(receiptData)
            }
        }
        
        // Reads the backup data.
        let uPersister = DYFStoreUserDefaultsPersistence()
        if uPersister.containsTransaction(identifier) {
            
            let transaction = uPersister.retrieveTransaction(identifier)
            if let tx = transaction {
                DYFStoreLog("[BAK] transaction.state: \(tx.state)")
                DYFStoreLog("[BAK] transaction.productIdentifier: \(tx.productIdentifier!)")
                DYFStoreLog("[BAK] transaction.transactionIdentifier: \(tx.transactionIdentifier!)")
                DYFStoreLog("[BAK] transaction.transactionTimestamp: \(tx.transactionTimestamp!)")
                
                if let receiptData = tx.transactionReceipt!.base64DecodedData() {
                    DYFStoreLog("[BAK] transaction.transactionReceipt: \(receiptData)")
                }
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
            let store = DYFStore.default
            let persister = store.keychainPersister!
            
            let transaction = DYFStoreTransaction()
            transaction.productIdentifier = info.productIdentifier
            if info.state! == .succeeded {
                transaction.state = DYFStoreTransactionState.purchased.rawValue
            } else if info.state! == .restored {
                transaction.state = DYFStoreTransactionState.restored.rawValue
                transaction.originalTransactionTimestamp = info.originalTransactionDate?.timestamp()
                transaction.originalTransactionIdentifier = info.originalTransactionIdentifier
            }
            
            transaction.transactionTimestamp = info.transactionDate?.timestamp()
            transaction.transactionIdentifier = info.transactionIdentifier
            transaction.transactionReceipt = data.base64EncodedString()
            persister.storeTransaction(transaction)
            
            // Makes the backup data.
            let uPersister = DYFStoreUserDefaultsPersistence()
            if !uPersister.containsTransaction(info.transactionIdentifier!) {
                uPersister.storeTransaction(transaction)
            }
            
            self.verifyReceipt(data)
        } catch let error {
            
            DYFStoreLog("error: \(error.localizedDescription)")
            self.refreshReceipt()
            
            return
        }
    }
    
    private func refreshReceipt() {
        DYFStoreLog()
        self.showLoading("Refresh receipt...")
        
        DYFStore.default.refreshReceipt(onSuccess: {
            self.storeReceipt()
        }) { (error) in
            self.failToRefreshReceipt()
        }
    }
    
    private func failToRefreshReceipt() {
        DYFStoreLog()
        self.hideLoading()
        
        self.showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                       message: "Fail to refresh receipt! Please check if your device can access the internet.",
                       cancelButtonTitle: "Cancel",
                       cancel: { (cancelAction) in },
                       confirmButtonTitle: NSLocalizedString("Retry", tableName: nil, comment: ""))
        { (action) in
            self.refreshReceipt()
        }
    }
    
    // It is better to use your own server with the parameters that was uploaded from the client to verify the receipt from the apple itunes store server (C -> Uploaded Parameters -> S -> Apple iTunes Store S -> S -> Receive Data -> C).
    private func verifyReceipt(_ receiptData: Data?) {
        DYFStoreLog()
        
        self.hideLoading()
        self.showLoading("Verify receipt...")
        
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
        let store = DYFStore.default
        let persister = store.keychainPersister!
        
        let identifier = info.transactionIdentifier!
        let transaction = persister.retrieveTransaction(identifier)
        if let tx = transaction, let receiptData = tx.transactionReceipt!.base64DecodedData() {
            self.verifyReceipt(receiptData)
        }
    }
    
    private func sendNotice(_ message: String) {
        self.showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
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
        
        self.hideLoading()
        self.showTipsMessage("Purchase Successfully")
        
        DispatchQueue.main.asyncAfter(delay: 1.5) {
            let info = self.purchaseInfo!
            let store = DYFStore.default
            let persister = store.keychainPersister!
            let identifier = info.transactionIdentifier!
            
            if info.state! == .restored {
                let transaction = store.extractRestoredTransaction(identifier)
                store.finishTransaction(transaction)
                
                persister.removeTransaction(info.originalTransactionIdentifier!)
            } else {
                
                let transaction = store.extractPurchasedTransaction(identifier)
                // The transaction can be finished only after the receipt verification passed under the client and the server can adopt the communication of security and data encryption. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction.
                store.finishTransaction(transaction)
            }
            
            persister.removeTransaction(identifier)
        }
        
    }
    
    public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {
        
        // Prints the reason of the error.
        DYFStoreLog("error: \(error.code), \(error.localizedDescription)")
        self.hideLoading()
        
        // An error occurs that has nothing to do with in-app purchase. Maybe it's the internet.
        if error.code < 21000 {
            
            // After several attempts, you can cancel refreshing receipt.
            self.showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
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
        
        self.showTipsMessage("Fail to purchase product!")
        
        DispatchQueue.main.asyncAfter(delay: 1.5) {
            let info = self.purchaseInfo!
            let store = DYFStore.default
            let persister = store.keychainPersister!
            let identifier = info.transactionIdentifier!
            
            if info.state! == .restored {
                let transaction = store.extractRestoredTransaction(identifier)
                store.finishTransaction(transaction)
                
                persister.removeTransaction(info.originalTransactionIdentifier!)
            } else {
                
                let transaction = store.extractPurchasedTransaction(identifier)
                // The transaction can be finished only after the receipt verification passed under the client and the server can adopt the communication of security and data encryption. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction.
                store.finishTransaction(transaction)
            }
            
            persister.removeTransaction(identifier)
        }
    }
    
}
