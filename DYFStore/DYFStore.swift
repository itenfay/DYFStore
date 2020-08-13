//
//  DYFStore.swift
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
import StoreKit

/// A StoreKit wrapper for in-app purchase.
open class DYFStore: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    /// Whether to enable log. The default is false.
    public var enableLog: Bool = false
    
    /// The valid products that were available for sale in the App Store.
    public var availableProducts: NSMutableArray!
    /// The product identifiers were invalid.
    public var invalidIdentifiers: NSMutableArray!
    
    /// Records those transcations that have been purchased.
    public var purchasedTranscations: NSMutableArray!
    /// Records those transcations that have been restored.
    public var restoredTranscations: NSMutableArray!
    
    /// The delegate processes the purchase which was initiated by user from the App Store.
    public weak var delegate: DYFStoreAppStorePaymentDelegate?
    
    /// The keychain persister that supervises the `DYFStoreTransaction` transactions.
    public var keychainPersister: DYFStoreKeychainPersistence?
    
    /// Returns a store singleton.
    public static let `default` = DYFStore()
    
    /// Constructs a store singleton with class method.
    ///
    /// - Returns: A store singleton.
    public class func defaultStore() -> DYFStore {
        return DYFStore.self.default
    }
    
    /// A struct named "Inner".
    // private struct Inner {
    //    static var instance: DYFStore? = nil
    // }
    
    /// Returns a store singleton.
    ///
    /// DispatchQueue.once(token: "com.storekit.DYFStore") {
    ///    if Inner.instance == nil {
    ///        Inner.instance = DYFStore()
    ///    }
    /// }
    /// return instance
    ///
    // public class var `default`: DYFStore {
    //
    //    objc_sync_enter(self)
    //    defer { objc_sync_exit(self) }
    //
    //    guard let instance = Inner.instance else {
    //        let store = DYFStore()
    //        Inner.instance = store
    //        return store
    //    }
    //
    //    return instance
    // }
    
    /// Overrides default constructor.
    private override init() {
        super.init()
        
        self.availableProducts  = NSMutableArray(capacity: 0)
        self.invalidIdentifiers = NSMutableArray(capacity: 0)
        
        self.purchasedTranscations = NSMutableArray(capacity: 0)
        self.restoredTranscations  = NSMutableArray(capacity: 0)
    }
    
    /// deinit
    deinit {
        removePaymentTransactionObserver()
    }
    
    /// Make sure the class has only one instance.
    open override func copy() -> Any {
        return self
    }
    
    /// Make sure the class has only one instance.
    open override func mutableCopy() -> Any {
        return self
    }
    
    // MARK: - StoreKit Wrapper
    
    /// Adds an observer to the payment queue. This must be invoked after the app has finished launching.
    public func addPaymentTransactionObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    /// Removes an observer from the payment queue.
    private func removePaymentTransactionObserver() {
        SKPaymentQueue.default().remove(self)
    }
    
    /// Whether the user is allowed to make payments.
    ///
    /// - Returns: NO if this device is not able or allowed to make payments.
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Accepts the response from the App Store that contains the requested product information.
    private var productsRequestDidFinish: (([SKProduct], [String]) -> Void)?
    /// Tells the user that the request failed to execute.
    private var productsRequestDidFail: ((NSError) -> Void)?
    
    /// An object that can retrieve localized information from the App Store about a specified list of products.
    private var productsRequest: SKProductsRequest?
    
    /// Requests localized information about a product from the Apple App Store. `success` will be called if the products request is successful, `failure` if it isn't.
    ///
    /// - Parameters:
    ///   - id: The product identifier for the product you wish to retrieve information of.
    ///   - success: The closure to be called if the products request is sucessful. Can be `nil`. It takes two parameters: `products`, an array of SKProducts, one product for each valid product identifier provided in the original request, and `invalidProductIdentifiers`, an array of product identifiers that were not recognized by the App Store.
    ///   - failure: The closure to be called if the products request fails. Can be `nil`.
    public func requestProduct(withIdentifier id: String?, success: @escaping ([SKProduct], [String]) -> Void, failure: @escaping (NSError) -> Void) {
        
        guard let identifier = id, !identifier.isEmpty else {
            
            self.productsRequestDidFail = failure
            
            DYFStoreLog("This product identifier is null or empty")
            
            let errDesc = NSLocalizedString("This product identifier is null or empty", tableName: "DYFStore", comment: "Error description")
            let userInfo = [NSLocalizedDescriptionKey: errDesc]
            let error = NSError(domain: DYFStoreError.domain,
                                code: DYFStoreError.invalidParameter.rawValue,
                                userInfo: userInfo)
            
            self.productsRequestDidFail?(error)
            
            return
        }
        
        DYFStoreLog()
        
        self.requestProduct(withIdentifiers: [identifier], success: success, failure: failure)
    }
    
    /// Requests localized information about a set of products from the Apple App Store. `success` will be called if the products request is successful, `failure` if it isn't.
    ///
    /// - Parameters:
    ///   - ids: The array of product identifiers for the products you wish to retrieve information of.
    ///   - success: The closure to be called if the products request is sucessful. Can be `nil`. It takes two parameters: `products`, an array of SKProducts, one product for each valid product identifier provided in the original request, and `invalidProductIdentifiers`, an array of product identifiers that were not recognized by the App Store.
    ///   - failure: The closure to be called if the products request fails. Can be `nil`.
    public func requestProduct(withIdentifiers ids: Array<String>?, success: @escaping ([SKProduct], [String]) -> Void, failure: @escaping (NSError) -> Void) {
        
        guard let identifiers = ids, !identifiers.isEmpty else {
            
            self.productsRequestDidFail = failure
            
            DYFStoreLog("An array of product identifiers is null or empty")
            
            let errorDesc = NSLocalizedString("An array of product identifiers is null or empty", tableName: "DYFStore", comment: "Error description")
            let userInfo = [NSLocalizedDescriptionKey: errorDesc]
            let error = NSError(domain: DYFStoreError.domain,
                                code: DYFStoreError.invalidParameter.rawValue,
                                userInfo: userInfo)
            
            self.productsRequestDidFail?(error)
            
            return
        }
        
        DYFStoreLog("product identifiers: \(identifiers)")
        
        if self.productsRequest == nil {
            
            self.productsRequestDidFinish = success
            self.productsRequestDidFail = failure
            
            let setOfProductId = Set<String>(identifiers)
            // Creates a product request object and initialize it with our product identifiers.
            self.productsRequest = SKProductsRequest(productIdentifiers: setOfProductId)
            self.productsRequest?.delegate = self;
            // Sends the request to the App Store.
            self.productsRequest?.start()
        }
    }
    
    // MARK: - Product management
    
    /// Whether the product is contained in the list of available products.
    ///
    /// - Parameter product: An `SKProduct` object.
    /// - Returns: True if it is contained, otherwise, false.
    public func containsProduct(_ product: SKProduct) -> Bool {
        var shouldContain: Bool = false
        
        for e in self.availableProducts {
            let aProduct = e as! SKProduct
            let id = aProduct.productIdentifier
            
            if id == product.productIdentifier {
                shouldContain = true
                break
            }
        }
        
        return shouldContain
    }
    
    /// Fetches the product by matching a given product identifier.
    ///
    /// - Parameter productIdentifier: A given product identifier.
    /// - Returns: An `SKProduct` object.
    public func product(forIdentifier productIdentifier: String) -> SKProduct? {
        var product: SKProduct? = nil
        
        for e in self.availableProducts {
            let aProduct = e as! SKProduct
            let id = aProduct.productIdentifier
            
            if id == productIdentifier {
                product = aProduct
                break
            }
        }
        
        return product
    }
    
    /// Fetches the localized price of a given product.
    ///
    /// - Parameter product: A given product.
    /// - Returns: The localized price of a given product.
    public func localizedPrice(ofProduct product: SKProduct?) -> String? {
        
        if let p = product {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
            numberFormatter.numberStyle = NumberFormatter.Style.currency
            numberFormatter.locale = product!.priceLocale
            
            let formattedString = numberFormatter.string(from: p.price)
            
            return formattedString
        }
        
        return nil
    }
    
    // MARK: - SKProductsRequestDelegate
    
    // Accepts the response from the App Store that contains the requested product information.
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DYFStoreLog("products request received response")
        
        /// The array contains products whose identifiers have been recognized by the App Store.
        let products: [SKProduct] = response.products
        /// The array contains all product identifiers have not been recognized by the App Store.
        let invalidProductIdentifiers = response.invalidProductIdentifiers
        
        for product in products {
            DYFStoreLog("received product with id: \(product.productIdentifier)")
            
            if !self.containsProduct(product) {
                self.availableProducts.add(product)
            }
        }
        
        for (idx, value) in invalidProductIdentifiers.enumerated() {
            DYFStoreLog("invalid product with id: \(value), index: \(idx)")
            
            if !self.invalidIdentifiers.contains(value) {
                self.invalidIdentifiers.add(value)
            }
        }
        
        DispatchQueue.main.async {
            self.productsRequestDidFinish?(products, invalidProductIdentifiers)
        }
    }
    
    // MARK: - SKRequestDelegate
    
    // Tells the delegate that the request has completed. When this method is called, your delegate receives no further communication from the request and can release it.
    public func requestDidFinish(_ request: SKRequest) {
        
        if let req = self.productsRequest, req === request {
            
            DYFStoreLog("products request finished")
            
            self.productsRequest = nil
            
        } else if let req = self.refreshReceiptRequest, req === request {
            
            DYFStoreLog("refresh receipt finished")
            
            DispatchQueue.main.async {
                self.refreshReceiptSuccessBlock?()
            }
            
            self.refreshReceiptRequest = nil
        }
    }
    
    // Tells the delegate that the request failed to execute. The requestDidFinish(_:) method is not called after this method is called.
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
        let err = error as NSError
        
        if let req = self.productsRequest, req === request {
            
            // Prints the cause of the product request failure.
            DYFStoreLog("products request failed with error: \(err.code), \(err.localizedDescription)")
            
            DispatchQueue.main.async {
                self.productsRequestDidFail?(err)
            }
            
            self.productsRequest = nil
            
        } else if let req = self.refreshReceiptRequest, req === request {
            
            DYFStoreLog("refresh receipt failed with error: \(err.code), \(err.localizedDescription)")
            
            DispatchQueue.main.async {
                self.refreshReceiptFailureBlock?(err)
            }
            
            self.refreshReceiptRequest = nil
        }
    }
    
    // MARK: - Posts Notification
    
    /// Creates a notification with a given name and sender and posts it to the notification center.
    ///
    /// - Parameters:
    ///   - name: The name of the notification. The default is DYFStore.purchasedNotification.
    ///   - info: The `DYFStore.NotificationInfo` object posting the notification.
    fileprivate func postNotification(withName name: Notification.Name = DYFStore.purchasedNotification, _ info: DYFStore.NotificationInfo) {
        NotificationCenter.default.post(name: name, object: info)
    }
    
    // MARK: - Purchases Product
    
    /// Whether there are purchases.
    ///
    /// - Returns: YES if it contains some items and NO, otherwise.
    public func hasPurchasedTransactions() -> Bool {
        return self.purchasedTranscations.count > 0
    }
    
    /// Whether there are restored purchases.
    ///
    /// - Returns: YES if it contains some items and NO, otherwise.
    public func hasRestoredTransactions() -> Bool {
        return self.restoredTranscations.count > 0
    }
    
    /// Extracts a purchased transaction with a given transaction identifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: A purchased `SKPaymentTransaction` object.
    public func extractPurchasedTransaction(_ transactionIdentifier: String?) -> SKPaymentTransaction? {
        
        var transaction: SKPaymentTransaction? = nil
        
        guard let transactionId = transactionIdentifier, !transactionId.isEmpty else {
            return transaction
        }
        
        self.purchasedTranscations.enumerateObjects { (obj: Any, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            
            let tempTransaction = obj as! SKPaymentTransaction
            
            let id = tempTransaction.transactionIdentifier ?? ""
            
            DYFStoreLog("index: \(idx), transactionId: \(id)")
            
            if id == transactionId {
                transaction = tempTransaction
            }
        }
        
        return transaction
    }
    
    /// Extracts a restored transaction with a given transaction identifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: A restored `SKPaymentTransaction` object.
    public func extractRestoredTransaction(_ transactionIdentifier: String?) -> SKPaymentTransaction? {
        
        var transaction: SKPaymentTransaction? = nil
        
        guard let transactionId = transactionIdentifier, !transactionId.isEmpty else {
            return transaction
        }
        
        self.restoredTranscations.enumerateObjects { (obj: Any, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            
            let tempTransaction = obj as! SKPaymentTransaction
            
            let id = tempTransaction.transactionIdentifier ?? ""
            let originalId = tempTransaction.original?.transactionIdentifier ?? ""
            
            DYFStoreLog("index: \(idx), transactionId: \(id), originalTransactionId: \(originalId)")
            
            if id == transactionId {
                transaction = tempTransaction
            }
        }
        
        return transaction
    }
    
    /// The number of items the user wants to purchase. It must be greater than 0, the default value is 1.
    public private(set) var quantity: Int = 1
    
    /// Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system and the number of items the user wants to purchase.
    ///
    /// - Parameters:
    ///   - productIdentifier: The identifier of the product whose payment will be requested.
    ///   - userIdentifier: An opaque identifier for the user’s account on your system. The recommended implementation is to use a one-way hash of the user’s account name to calculate the value for this property.
    ///   - quantity: The number of items the user wants to purchase. The default value is 1.
    public func purchaseProduct(_ productIdentifier: String?, userIdentifier: String? = nil, quantity: Int = 1) {
        
        guard let identifier = productIdentifier, !identifier.isEmpty else {
            
            DYFStoreLog("The given product identifier is null or empty")
            
            let errDesc = NSLocalizedString("The given product identifier is null or empty", tableName: "DYFStore", comment: "Error description")
            let userInfo = [NSLocalizedDescriptionKey: errDesc]
            let error = NSError(domain: DYFStoreError.domain,
                                code: DYFStoreError.invalidParameter.rawValue,
                                userInfo: userInfo)
            
            var info = DYFStore.NotificationInfo()
            info.state = DYFStore.PurchaseState.failed
            info.error = error
            self.postNotification(withName: DYFStore.purchasedNotification, info)
            
            return
        }
        
        if let product = self.product(forIdentifier: identifier) {
            
            DYFStoreLog("productIdentifier: \(identifier), quantity: \(quantity)")
            
            self.quantity = quantity
            
            let payment = SKMutablePayment(product: product)
            payment.quantity = quantity
            if #available(iOS 7.0, *) {
                payment.applicationUsername = userIdentifier
            }
            SKPaymentQueue.default().add(payment)
            
        } else {
            
            DYFStoreLog("Unknown product identifier: \(identifier)")
            
            let errDesc = NSLocalizedString("Unknown product identifier", tableName: "DYFStore", comment: "Error description")
            let userInfo = [NSLocalizedDescriptionKey: errDesc]
            let error = NSError(domain: DYFStoreError.domain,
                                code: DYFStoreError.unknownProductIdentifier.rawValue,
                                userInfo: userInfo)
            
            var info = DYFStore.NotificationInfo()
            info.state = DYFStore.PurchaseState.failed
            info.productIdentifier = identifier
            info.error = error
            self.postNotification(withName: DYFStore.purchasedNotification, info)
        }
    }
    
    /// Requests to restore previously completed purchases that refer to auto-renewable subscriptions, free subscriptions or non-expendable items.
    ///
    /// The usage scenes are as follows:
    /// The apple users log in to other devices and install app.
    /// The app corresponding to in-app purchase has been uninstalled and reinstalled.
    ///
    /// - Parameter userIdentifier: An opaque identifier for the user’s account on your system.
    public func restoreTransactions(userIdentifier: String? = nil) {
        self.restoredTranscations = NSMutableArray(capacity: 0)
        
        if let identifier = userIdentifier, !identifier.isEmpty {
            
            assert(SKPaymentQueue.default().responds(to: #selector(SKPaymentQueue.restoreCompletedTransactions(withApplicationUsername:))), "restoreCompletedTransactions(withApplicationUsername:) not supported in this iOS version. Use restoreCompletedTransactions() instead.")
            
            if #available(iOS 7.0, *) {
                SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: identifier)
            } else {
                SKPaymentQueue.default().restoreCompletedTransactions()
            }
            
        } else {
            
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    /// Completes a pending transaction.
    ///
    /// Your application should call this method from a transaction observer that received a notification from the payment queue. Calling finishTransaction(_:) on a transaction removes it from the queue. Your application should call finishTransaction(_:) only after it has successfully processed the transaction and unlocked the functionality purchased by the user.
    /// Calling finishTransaction(_:) on a transaction that is in the SKPaymentTransactionState.purchasing state throws an exception.
    ///
    /// - Parameter transaction: The transaction to finish.
    public func finishTransaction(_ transaction: SKPaymentTransaction?) {
        if let tx = transaction {
            DYFStoreLog("transactionIdentifier: \(tx.transactionIdentifier ?? "")")
            SKPaymentQueue.default().finishTransaction(tx)
        }
    }
    
    // MARK: - Receipt
    
    /// Fetches the url of the bundle’s App Store receipt, or nil if the receipt is missing.
    /// If this method returns `nil` you should refresh the receipt by calling `refreshReceipt`.
    ///
    /// - Returns: The url of the bundle’s App Store receipt.
    public class func receiptURL() -> URL? {
        // The general best practice of weak linking using the respondsToSelector: method cannot be used here. Prior to iOS 7, the method was implemented as private API, but that implementation called the doesNotRecognizeSelector: method.
        assert(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1, "appStoreReceiptURL not supported in this iOS version.")
        let receiptURL = Bundle.main.appStoreReceiptURL
        return receiptURL
    }
    
    /// The block to be called if the refresh receipt request is sucessful.
    private var refreshReceiptSuccessBlock: (() -> Void)?
    /// The block to be called if the refresh receipt request fails.
    private var refreshReceiptFailureBlock: ((NSError) -> Void)?
    
    /// A request to refresh the receipt, which represents the user's transactions with your app.
    private var refreshReceiptRequest: SKReceiptRefreshRequest?
    
    /// Requests to refresh the App Store receipt in case the receipt is invalid or missing. `successBlock` will be called if the refresh receipt request is successful, `failureBlock` if it isn't.
    ///
    /// - Parameters:
    ///   - successBlock: The block to be called if the refresh receipt request is sucessful. Can be `nil`.
    ///   - failureBlock: The block to be called if the refresh receipt request fails. Can be `nil`.
    public func refreshReceipt(onSuccess successBlock: @escaping () -> Void, failure failureBlock: @escaping (NSError) -> Void) {
        
        if self.refreshReceiptRequest == nil {
            
            self.refreshReceiptSuccessBlock = successBlock
            self.refreshReceiptFailureBlock = failureBlock
            
            self.refreshReceiptRequest = SKReceiptRefreshRequest(receiptProperties: [:])
            self.refreshReceiptRequest?.delegate = self
            self.refreshReceiptRequest?.start()
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    // Tells an observer that one or more transactions have been updated.
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchasing:
                self.purchasingTransaction(transaction, queue: queue)
                break
            case .purchased:
                self.didPurchaseTransaction(transaction, queue: queue)
                break
            case .failed:
                self.didFailWithTransaction(transaction, queue: queue, error: transaction.error! as NSError)
                break
            case .restored:
                self.didRestoreTransaction(transaction, queue: queue)
                break
            case .deferred:
                self.didDeferTransaction(transaction, queue: queue)
                break
            @unknown default:
                DYFStoreLog("Unknown transaction state")
                break
            }
            
        }
    }
    
    // Tells the observer that the payment queue has updated one or more download objects.
    public func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        
        for download in downloads {
            
            let state = self.state(forDownload: download)
            switch state {
                
            case .waiting:
                DYFStoreLog("The download is inactive, waiting to be downloaded")
                //queue.start([download])
                break
            case .active:
                self.didUpdateDownload(download, queue: queue)
                break
            case .paused:
                self.didPauseDownload(download, queue: queue)
                break
            case .finished:
                self.didFinishDownload(download, queue: queue)
                break
            case .failed:
                self.didFailWithDownload(download, queue: queue)
                break
            case .cancelled:
                self.didCancelDownload(download, queue: queue)
                break
            }
            
        }
    }
    
    // Tells the observer that the payment queue has finished sending restored transactions.
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DYFStoreLog("The payment queue has finished sending restored transactions")
    }
    
    // Tells the observer that an error occurred while restoring transactions.
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let err = error as NSError
        
        DYFStoreLog("The restored transactions failed with error: \(err.code), \(err.localizedDescription)")
        
        var info = DYFStore.NotificationInfo()
        
        // The user cancels the purchase.
        if err.code == SKError.paymentCancelled.rawValue {
            info.state = DYFStore.PurchaseState.cancelled
        } else {
            info.state = DYFStore.PurchaseState.restoreFailed
        }
        
        info.error = err
        
        self.postNotification(info)
    }
    
    // Tells an observer that one or more transactions have been removed from the queue.
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            // Logs all transactions that have been removed from the payment queue.
            let productId = transaction.payment.productIdentifier
            DYFStoreLog("\(productId) has been removed from the payment queue")
        }
    }
    
    // Tells the observer that a user initiated an in-app purchase from the App Store.
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        
        if #available(iOS 11.0, *) {
            
            if !containsProduct(product) {
                self.availableProducts.add(product)
            }
            
            self.delegate?.didReceiveAppStorePurchaseRequest(queue, payment: payment, forProduct: product)
            
        } else { /* Fallback on earlier versions. Never execute. */ }
        
        return false
    }
    
    // MARK: - Process Transaction
    
    /// The transaction is being processed by the App Store.
    ///
    /// - Parameters:
    ///   - transaction: An `SKPaymentTransaction` object in the payment queue.
    ///   - queue: The payment queue that updated the transactions.
    private func purchasingTransaction(_ transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        DYFStoreLog("The transaction is purchasing")
        
        var info = DYFStore.NotificationInfo()
        info.state = DYFStore.PurchaseState.purchasing
        self.postNotification(info)
    }
    
    /// The App Store successfully processed payment. Your application should provide the content the user purchased.
    ///
    /// - Parameters:
    ///   - transaction: An `SKPaymentTransaction` object in the payment queue.
    ///   - queue: The payment queue that updated the transactions.
    private func didPurchaseTransaction(_ transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        DYFStoreLog("The transaction purchased. Deliver the content for \(transaction.payment.productIdentifier)")
        
        self.purchasedTranscations.add(transaction)
        // Checks whether the purchased product has content hosted with Apple.
        if transaction.downloads.count > 0 {
            
            // Starts the download process and send a DYFStoreDownload.State.started notification.
            queue.start(transaction.downloads)
            
            var info = DYFStore.NotificationInfo()
            info.downloadState = DYFStoreDownload.State.started
            self.postNotification(withName: DYFStore.downloadedNotification, info)
            
        } else {
            
            self.didFinishTransaction(transaction, queue: queue, forState: DYFStore.PurchaseState.succeeded)
        }
    }
    
    /// The transaction failed. Check the error property to determine what happened.
    ///
    /// - Parameters:
    ///   - transaction: An `SKPaymentTransaction` object in the payment queue.
    ///   - queue: The payment queue that updated the transactions.
    ///   - error: An object describing the error that occurred while processing the transaction.
    private func didFailWithTransaction(_ transaction: SKPaymentTransaction, queue: SKPaymentQueue, error: NSError) {
        
        DYFStoreLog("The transaction failed with product(\(transaction.payment.productIdentifier)) and error(\(error.debugDescription))")
        
        var info = DYFStore.NotificationInfo()
        
        // The user cancels the purchase.
        if error.code == SKError.paymentCancelled.rawValue {
            info.state = DYFStore.PurchaseState.cancelled
        } else {
            info.state = DYFStore.PurchaseState.failed
        }
        
        info.error = error
        info.productIdentifier = transaction.payment.productIdentifier
        
        self.postNotification(info)
        self.finishTransaction(transaction)
    }
    
    /// This transaction restores content previously purchased by the user. Read the original property to obtain information about the original purchase.
    ///
    /// - Parameters:
    ///   - transaction: An `SKPaymentTransaction` object in the payment queue.
    ///   - queue: The payment queue that updated the transactions.
    private func didRestoreTransaction(_ transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        
        DYFStoreLog("The transaction restored. Restore the content for \(transaction.payment.productIdentifier)")
        
        self.restoredTranscations.add(transaction)
        // Sends a DYFStoreDownload.State.started notification if it has.
        if transaction.downloads.count > 0 {
            
            queue.start(transaction.downloads)
            
            var info = DYFStore.NotificationInfo()
            info.downloadState = DYFStoreDownload.State.started
            self.postNotification(withName: DYFStore.downloadedNotification, info)
            
        } else {
            
            self.didFinishTransaction(transaction, queue: queue, forState: DYFStore.PurchaseState.restored)
        }
    }
    
    /// The transaction is in the queue, but its final status is pending external action such as Ask to Buy. Update your UI to show the deferred state, and wait for another callback that indicates the final status.
    ///
    /// - Parameters:
    ///   - transaction: An `SKPaymentTransaction` object in the payment queue.
    ///   - queue: The payment queue that updated the transactions.
    private func didDeferTransaction(_ transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        // Do not block your UI. Allow the user to continue using your app.
        DYFStoreLog("The transaction deferred. Do not block your UI. Allow the user to continue using your app.")
        
        var info = DYFStore.NotificationInfo()
        info.state = DYFStore.PurchaseState.deferred
        self.postNotification(info)
    }
    
    /// Notifies the user about the purchase process finished.
    ///
    /// - Parameters:
    ///   - transaction: An `SKPaymentTransaction` object in the payment queue.
    ///   - queue: The payment queue that updated the transactions.
    ///   - forState: The state of purchase.
    private func didFinishTransaction(_ transaction: SKPaymentTransaction, queue: SKPaymentQueue, forState state: DYFStore.PurchaseState) {
        
        var info = DYFStore.NotificationInfo()
        info.state = state
        info.productIdentifier = transaction.payment.productIdentifier
        if #available(iOS 7.0, *) {
            info.userIdentifier = transaction.payment.applicationUsername
        }
        info.transactionDate = transaction.transactionDate
        info.transactionIdentifier = transaction.transactionIdentifier
        
        if let originalTx = transaction.original {
            info.originalTransactionDate = originalTx.transactionDate
            info.originalTransactionIdentifier = originalTx.transactionIdentifier
        }
        
        self.postNotification(info)
    }
    
    // MARK: - Download Transaction
    
    private func didUpdateDownload(_ download: SKDownload, queue: SKPaymentQueue) {
        DYFStoreLog("The download(\(download.contentIdentifier)) for product(\(download.transaction.payment.productIdentifier)) updated")
        
        // The content is being downloaded. Let's provide a download progress to the user.
        var info = DYFStore.NotificationInfo()
        info.downloadState = DYFStoreDownload.State.inProgress
        info.downloadProgress = download.progress * 100
        
        self.postNotification(withName: DYFStore.downloadedNotification, info)
    }
    
    private func didPauseDownload(_ download: SKDownload, queue: SKPaymentQueue) {
        DYFStoreLog("The download(\(download.contentIdentifier)) for product(\(download.transaction.payment.productIdentifier)) paused")
    }
    
    private func didCancelDownload(_ download: SKDownload, queue: SKPaymentQueue) {
        let transaction: SKPaymentTransaction = download.transaction
        
        DYFStoreLog("The download(\(download.contentIdentifier)) for product(\(transaction.payment.productIdentifier)) canceled")
        
        // StoreKit saves your downloaded content in the Caches directory. Let's remove it.
        do {
            try FileManager.default.removeItem(at: download.contentURL ?? URL(string: "")!)
        } catch let error {
            DYFStoreLog("FileManager.default.removeItem(at:): \(error.localizedDescription)")
        }
        
        var info = DYFStore.NotificationInfo()
        info.downloadState = DYFStoreDownload.State.cancelled
        self.postNotification(withName: DYFStore.downloadedNotification, info)
        
        let hasPendingDownloads = DYFStore.hasPendingDownloadsInTransaction(transaction)
        if !hasPendingDownloads {
            
            let errDesc = NSLocalizedString("The download cancelled", tableName: "DYFStore", comment: "Error description")
            let userInfo = [NSLocalizedDescriptionKey: errDesc]
            let error = NSError(domain: DYFStoreError.domain,
                                code: DYFStoreError.Code.downloadCancelled.rawValue,
                                userInfo: userInfo)
            
            self.didFailWithTransaction(transaction, queue: queue, error: error)
        }
    }
    
    private func didFailWithDownload(_ download: SKDownload, queue: SKPaymentQueue) {
        let transaction: SKPaymentTransaction = download.transaction
        let error = download.error! as NSError
        
        DYFStoreLog("The download(\(download.contentIdentifier)) for product(\(transaction.payment.productIdentifier)) failed with error(\(error.localizedDescription))")
        
        // If a download fails, remove it from the Caches, then finish the transaction.
        // It is recommended to retry downloading the content in this case.
        do {
            try FileManager.default.removeItem(at: download.contentURL ?? URL(string: "")!)
        } catch let error {
            DYFStoreLog("FileManager.default.removeItem(at:): \(error.localizedDescription)")
        }
        
        var info = DYFStore.NotificationInfo()
        info.downloadState = DYFStoreDownload.State.failed
        info.error = error
        self.postNotification(withName: DYFStore.downloadedNotification, info)
        
        let hasPendingDownloads = DYFStore.hasPendingDownloadsInTransaction(transaction)
        if !hasPendingDownloads {
            self.didFailWithTransaction(transaction, queue: queue, error: error)
        }
    }
    
    private func didFinishDownload(_ download: SKDownload, queue: SKPaymentQueue) {
        let transaction: SKPaymentTransaction = download.transaction
        
        // The download is complete. StoreKit saves the downloaded content in the Caches directory.
        DYFStoreLog("The download(\(download.contentIdentifier)) for product(\(transaction.payment.productIdentifier)) finished. Location of downloaded file(\(download.contentURL!.absoluteString))")
        
        // Post a DYFStoreDownload.State.succeeded notification if the download is completed.
        var info = DYFStore.NotificationInfo()
        info.downloadState = DYFStoreDownload.State.succeeded
        self.postNotification(withName: DYFStore.downloadedNotification, info)
        
        // It indicates whether all content associated with the transaction were downloaded.
        var allAssetsDownloaded: Bool = true
        if DYFStore.hasPendingDownloadsInTransaction(transaction) {
            // We found an ongoing download. Therefore, there are still pending downloads.
            allAssetsDownloaded = false
        }
        
        if allAssetsDownloaded {
            
            var state: DYFStore.PurchaseState
            
            if transaction.transactionState == .restored {
                state = DYFStore.PurchaseState.restored
            } else {
                state = DYFStore.PurchaseState.succeeded
            }
            
            self.didFinishTransaction(transaction, queue: queue, forState:state)
        }
    }
    
    /// Returns the state that a download operation can be in.
    ///
    /// - Parameter download: Downloadable content associated with a product.
    /// - Returns: The state that a download operation can be in.
    private func state(forDownload download: SKDownload) -> SKDownloadState {
        
        var state: SKDownloadState
        
        if #available(iOS 12.0, *) {
            state = download.state
        } else {
            state = download.downloadState
        }
        
        return state
    }
    
    /// Whether there are pending downloads in the transaction.
    ///
    /// - Parameter transaction: An `SKPaymentTransaction` object in the payment queue.
    /// - Returns: YES if there are pending downloads and NO, otherwise.
    public class func hasPendingDownloadsInTransaction(_ transaction: SKPaymentTransaction) -> Bool {
        
        // A download is complete if its state is SKDownloadState.cancelled, SKDownloadState.failed, or SKDownloadState.finished
        // and pending, otherwise. We finish a transaction if and only if all its associated downloads are complete.
        // For the SKDownloadState.failed case, it is recommended to try downloading the content again before finishing the transaction.
        for download in transaction.downloads {
            
            let state = DYFStore.default.state(forDownload: download)
            
            switch state {
            case .active, .paused, .waiting:
                return true
            case .cancelled, .failed, .finished:
                continue
            }
        }
        
        return false
    }
    
}

// MARK: - Extension Date
extension Date {
    
    /// Returns a string representation of a given date formatted using the receiver’s current settings.
    ///
    /// - Returns: A string representation of a given date formatted using the receiver’s current settings.
    public func toString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateString = dateFormatter.string(from: self)
        
        return dateString
    }
    
    /// Returns a string representation of a given date formatted using the receiver’s current settings.
    ///
    /// - Returns: A string representation of a given date formatted using the receiver’s current settings.
    public func toGTMString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let dateString = dateFormatter.string(from: self)
        
        return dateString
    }
    
    /// Returns a time interval between the date object and 00:00:00 UTC on 1 January 1970.
    ///
    /// - Returns: A time interval between the date object and 00:00:00 UTC on 1 January 1970.
    public func timestamp() -> String {
        let timeInterval = self.timeIntervalSince1970
        return "\(timeInterval)"
    }
    
}

// MARK: - Data, Base64
extension Data {
    
    /// Creates a Base64, UTF-8 encoded data object from the data object.
    ///
    /// - Returns: A Base64, UTF-8 encoded data object.
    public func base64Encode() -> Data? {
        return self.base64EncodedData(options: [])
    }
    
    /// Creates a Base64 encoded string from the data object.
    ///
    /// - Returns: A Base64 encoded string.
    public func base64EncodedString() -> String? {
        return self.base64EncodedString(options: [])
    }
    
    /// Creates a data object with the given Base64 encoded data.
    ///
    /// - Returns: A data object containing the Base64 decoded data. Returns nil if the data object could not be decoded.
    public func base64Decode() -> Data? {
        return NSData(base64Encoded: self) as Data?
    }
    
    /// Creates a string object with the given Base64 encoded data.
    ///
    /// - Returns: A string object containing the Base64 decoded data. Returns nil if the data object could not be decoded.
    public func base64DecodedString() -> String? {
        
        guard let data = base64Decode() else {
            return nil
        }
        
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}

// MARK: - String, Base64
extension String {
    
    /// Creates and returns a date object set to the given number of seconds from 00:00:00 UTC on 1 January 1970.
    ///
    /// - Returns: A date object set to seconds seconds from the reference date.
    public func timestampToDate() -> Date {
        
        let s = NSString(string: self)
        let t: TimeInterval = s.doubleValue
        
        return Date(timeIntervalSince1970: t)
    }
    
    /// Creates a Base64 encoded string from the string.
    ///
    /// - Returns: A Base64 encoded string.
    public func base64Encode() -> String? {
        
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedString(options: [])
    }
    
    /// Creates a Base64, UTF-8 encoded data object from the string.
    ///
    /// - Returns: A Base64, UTF-8 encoded data object.
    public func base64EncodedData() -> Data? {
        
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedData(options: [])
    }
    
    /// Creates a string object with the given Base64 encoded string.
    ///
    /// - Returns: A string object built by Base64 decoding the provided string. Returns nil if the string object could not be decoded.
    public func base64Decode() -> String? {
        
        guard let data = base64EncodedData() else {
            return nil
        }
        
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    /// Creates a data object with the given Base64 encoded string.
    ///
    /// - Returns: A data object built by Base64 decoding the provided string. Returns nil if the string object could not be decoded.
    public func base64DecodedData() -> Data? {
        return NSData(base64Encoded: self, options: []) as Data?
    }
    
}

// MARK: - Extension DYFStore
extension DYFStore {
    
    /// Uses enumeration to inicate the state of purchase.
    public enum PurchaseState: UInt8 {
        
        /// Indicates that the state is purchasing.
        case purchasing
        
        /// Indicates the user cancels the purchase.
        case cancelled
        
        /// Indicates that the purchase failed.
        case failed
        
        /// Indicates that the purchase was successful.
        case succeeded
        
        /// Indicates that the restoring transaction was successful.
        case restored
        
        /// Indicates that the restoring transaction failed.
        case restoreFailed
        
        /// Indicates that the transaction was deferred.
        @available(iOS 8.0, *)
        case deferred
    }
    
    /// Provides notification about the purchase.
    public static let purchasedNotification: NSNotification.Name = NSNotification.Name(rawValue: "DYFStorePurchasedNotification")
    
    /// Provides notification about the download.
    public static let downloadedNotification: NSNotification.Name = NSNotification.Name(rawValue: "DYFStoreDownloadedNotification")
    
}

// MARK: - DYFStoreDownload
public struct DYFStoreDownload {
    
    /// Uses enumeration to inicate the state of download.
    public enum State: UInt8 {
        
        /// Indicates that downloading a hosted content has started.
        case started
        
        /// Indicates that a hosted content is currently being downloaded.
        case inProgress
        
        /// Indicates that your app cancelled the download.
        case cancelled
        
        /// Indicates that downloading a hosted content failed.
        case failed
        
        /// Indicates that a hosted content was successfully downloaded.
        case succeeded
    }
    
}

// MARK: - DYFStoreError
public struct DYFStoreError {
    
    /// The error domain for store.
    public static let domain: String = "SKErrorDomain.dyfstore"
    
    public enum Code: Int {
        
        /// Unknown product identifier.
        case unknownProductIdentifier = 100
        
        /// Invalid parameter indicates that the received value is nil or empty.
        case invalidParameter = 136
        
        /// Indicates that your app cancelled the download.
        case downloadCancelled = 300
    }
    
    public static var unknownProductIdentifier: DYFStoreError.Code {
        return DYFStoreError.Code(rawValue: 100)!
    }
    
    public static var invalidParameter: DYFStoreError.Code {
        return DYFStoreError.Code(rawValue: 136)!
    }
    
    public static var downloadCanceled: DYFStoreError.Code {
        return DYFStoreError.Code(rawValue: 300)!
    }
    
}

// MARK: - DYFStore.NotificationInfo
extension DYFStore {
    
    public struct NotificationInfo {
        
        /// The state of purchase.
        public var state: DYFStore.PurchaseState?
        
        /// The state of the download. Only valid if downloading a hosted content.
        public var downloadState: DYFStoreDownload.State?
        
        /// A value that indicates how much of the file has been downloaded. Only valid if state is DYFStoreDownload.State.inProgress.
        public var downloadProgress: Float = 0
        
        /// This indicates an error occurred.
        public var error: NSError?
        
        /// A string used to identify a product that can be purchased from within your app.
        public var productIdentifier: String?
        
        /// An opaque identifier for the user’s account on your system.
        public var userIdentifier: String?
        
        /// When a transaction is restored, the current transaction holds a new transaction date. Your app will read this property to retrieve the restored transaction date.
        public var originalTransactionDate: Date?
        
        /// When a transaction is restored, the current transaction holds a new transaction identifier. Your app will read this property to retrieve the restored transaction identifier.
        public var originalTransactionIdentifier: String?
        
        /// The date when the transaction was added to the server queue. Only valid if state is SKPaymentTransactionState.purchased or SKPaymentTransactionState.restored.
        public var transactionDate: Date?
        
        /// The transaction identifier of purchase.
        public var transactionIdentifier: String?
    }
    
}

/// Processes the purchase which was initiated by user from the App Store.
@objc public protocol DYFStoreAppStorePaymentDelegate: NSObjectProtocol {
    
    /// A user initiated an in-app purchase from the App Store.
    ///
    /// - Parameters:
    ///   - queue: The payment queue on which the payment request was made.
    ///   - payment: The payment request.
    ///   - product: The in-app purchase product.
    @available(iOS 11.0, *)
    @objc func didReceiveAppStorePurchaseRequest(_ queue: SKPaymentQueue, payment: SKPayment, forProduct product: SKProduct)
    
}

// MARK: - Extends the properties and method for the dispatch queue.
extension DispatchQueue {
    
    /// Declares an array of string to record the token.
    private static var _onceTracker = [String]()
    
    /// Executes a block of code associated with a given token, only once. The code is thread safe and will only execute the code once even in the presence of multi-thread calls.
    ///
    /// - Parameters:
    ///   - token: A unique idetifier.
    ///   - block: A block to execute once.
    public class func once(token: String, block: () -> Void) {
        
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        
        block()
    }
    
    /// Submits a task to a dispatch queue for asynchronous execution.
    ///
    /// - Parameter block: The block to be invoked on the queue.
    public func asyncTask(block: @escaping () -> Void) {
        self.async(execute: block)
    }
    
    /// Submits a task to a dispatch queue for asynchronous execution after a specified time.
    ///
    /// - Parameters:
    ///   - time: The block should be executed after a few time delay.
    ///   - block: The block to be invoked on the queue.
    public func asyncAfter(delay time: Double, block: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + time, execute: block)
    }
    
}

/// // Outputs log to the console in the process of purchasing the `SKProduct` product.
///
/// - Parameters:
///   - format: The format string.
///   - args: The arguments for outputting to the console.
///   - funcName: The name of a function.
///   - lineNum: The number of a code line.
public func DYFStoreLog(_ format: String = "", _ args: CVarArg..., funcName: String = #function, lineNum: Int = #line) {
    
    if DYFStore.default.enableLog {
        
        let fileName = (#file as NSString).lastPathComponent
        
        let output = String(format: format, args)
        
        print("[\(fileName):\(funcName)] [line: \(lineNum)]" + " [DYFStore] " + output)
    }
}
