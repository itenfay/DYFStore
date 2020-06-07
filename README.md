
[If this project can help you, please give it a star. Thanks!](https://github.com/dgynfi/DYFStore)


## DYFStore

A lightweight and easy-to-use iOS library for In-App Purchases. (Swift)

`DYFStore` uses blocks and [notifications](#Notifications) to wrap `StoreKit`, provides [receipt verification](#Receipt-verification) and [transaction persistence](#Transaction-persistence). `DYFStore` doesn't require any external dependencies. 

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/DYFStore.svg?style=flat)](http://cocoapods.org/pods/DYFStore)&nbsp;
![CocoaPods](http://img.shields.io/cocoapods/p/DYFStore.svg?style=flat)&nbsp;


## Features

- Super simple in-app purchases.
- Built-in support for remembering your purchases.
- Built-in receipt validation (remote).
- Built-in hosted content downloads and notifications.


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/dgynfi/DYFStore/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFStore', '~> 1.1.1'
```

Or

```
pod 'DYFStore'
```

Or add the files from the [DYFStore](https://github.com/dgynfi/DYFStore/tree/master/DYFStore) directory if you're doing it manually.

Check out the [wiki](https://github.com/dgynfi/DYFStore/wiki/Installation) for more options.


## Usage

Next I'll show you how to use `DYFStore`.

### Initialization

Initialization is as simple as the below.

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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
```

You can process the purchase which was initiated by user from the App Store and provide your own implementation using the `DYFStoreAppStorePaymentDelegate` protocol:

```
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
    
    DYFStore.default.purchaseProduct(product.productIdentifier, userIdentifier: userIdentifier)
}
```


### Request products

There are two strategies for retrieving information about the products from the App Store.

**Strategy 1:** To begin the purchase process, your app must know its product identifiers. Your app can uses a product identifier to fetch information about product available for sale in the App Store and to submit payment request directly.

```
@IBAction func fetchesProductAndSubmitsPayment(_ sender: Any) {
    self.showLoading("Loading...")
    
    let productId = "com.hncs.szj.coin42"
    
    DYFStore.default.requestProduct(withIdentifier: productId, success: { (products, invalidIdentifiers) in
        
        self.hideLoading()
        
        if products.count == 1 {
            
            let productId = products[0].productIdentifier
            self.addPayment(productId)
            
        } else {
            
            self.showTipsMessage("There is no this product for sale!")
        }
        
    }) { (error) in
        
        self.hideLoading()
        
        let value = error.userInfo[NSLocalizedDescriptionKey] as? String
        let msg = value ?? "\(error.localizedDescription)"
        self.sendNotice("An error occurs, \(error.code), " + msg)
    }
}

private func addPayment(_ productId: String) {
    
    // Get account name from your own user system.
    let accountName = "Handsome Jon"
    
    // This algorithm is negotiated with server developer.
    let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
    DYFStoreLog("userIdentifier: \(userIdentifier)")
    
    DYFStore.default.purchaseProduct(productId, userIdentifier: userIdentifier)
}
```

**Strategy 2:** To begin the purchase process, your app must know its product identifiers so it can retrieve information about the products from the App Store and present its store UI to the user. Every product sold in your app has a unique product identifier. Your app uses these product identifiers to fetch information about products available for sale in the App Store, such as pricing, and to submit payment requests when users purchase those products.

```
func fetchProductIdentifiersFromServer() -> [String] {
    
    let productIds = [
        "com.hncs.szj.coin42",   // 42 gold coins for ￥6.
        "com.hncs.szj.coin210",  // 210 gold coins for ￥30.
        "com.hncs.szj.coin686",  // 686 gold coins for ￥98.
        "com.hncs.szj.coin1386", // 1386 gold coins for ￥198.
        "com.hncs.szj.coin2086", // 2086 gold coins for ￥298.
        "com.hncs.szj.coin4886", // 4886 gold coins for ￥698.
        "com.hncs.szj.vip1",     // non-renewable vip subscription for a month.
        "com.hncs.szj.vip2"      // Auto-renewable vip subscription for three months.
    ]
    
    return productIds
}

@IBAction func fetchesProductsFromAppStore(_ sender: Any) {
    self.showLoading("Loading...")
    
    let productIds = fetchProductIdentifiersFromServer()
    
    DYFStore.default.requestProduct(withIdentifiers: productIds, success: { (products, invalidIdentifiers) in
        
        self.hideLoading()
        
        if products.count > 0 {
            
            self.processData(products)
            
        } else if products.count == 0 &&
            invalidIdentifiers.count > 0 {
            
            // Please check the product information you set up.
            self.showTipsMessage("There are no products for sale!")
        }
        
    }) { (error) in
        
        self.hideLoading()
        
        let value = error.userInfo[NSLocalizedDescriptionKey] as? String
        let msg = value ?? "\(error.localizedDescription)"
        self.sendNotice("An error occurs, \(error.code), " + msg)
    }
}

private func processData(_ products: [SKProduct]) {
    
    var modelArray = [DYFStoreProduct]()
    
    for product in products {
        
        let p = DYFStoreProduct()
        p.identifier = product.productIdentifier
        p.name = product.localizedTitle
        p.price = product.price.stringValue
        p.localePrice = DYFStore.default.localizedPrice(ofProduct: product)
        p.localizedDescription = product.localizedDescription
        
        modelArray.append(p)
    }
    
    self.displayStoreUI(modelArray)
}

private func displayStoreUI(_ dataArray: [DYFStoreProduct]) {
    
    if !DYFStore.canMakePayments() {
        self.showTipsMessage("Your device is not able or allowed to make payments!")
        return
    }
    
    let storeVC = DYFStoreViewController()
    storeVC.dataArray = dataArray
    self.navigationController?.pushViewController(storeVC, animated: true)
}
```


### Add payment

Whether the user is allowed to make payments.

```
if !DYFStore.canMakePayments() {
    self.showTipsMessage("Your device is not able or allowed to make payments!")
    return
}
```

If you need an opaque identifier for the user’s account on your system to add payment, you can use a one-way hash of the user’s account name to calculate the value for this property.

```
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
```

Requests payment of the product with the given product identifier.

```
DYFStore.default.purchaseProduct("com.hncs.szj.coin210")
```

Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.

```
DYFStore.default.purchaseProduct("com.hncs.szj.coin210", userIdentifier: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```


### Restore transactions

```
DYFStore.default.restoreTransactions()
```

Or

```
DYFStore.default.restoreTransactions(userIdentifier: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```


### Refresh receipt

```
DYFStore.default.refreshReceipt(onSuccess: {
    self.storeReceipt()
}) { (error) in
    self.failToRefreshReceipt()
}
```


### Notifications

`DYFStore` sends notifications of `StoreKit` related events and extends `NSNotification` to provide relevant information. To receive them, add the observer to `DYFStore`.

#### Add and remove the observer

```
func addStoreObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processPurchaseNotification(_:)), name: DYFStore.purchasedNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processDownloadNotification(_:)), name: DYFStore.downloadedNotification, object: nil)
}

func removeStoreObserver() {
    NotificationCenter.default.removeObserver(self, name: DYFStore.purchasedNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: DYFStore.downloadedNotification, object: nil)
}
```

#### Payment transaction notifications

Payment transaction notifications are sent after a payment has been requested or for each restored transaction.

```
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

```

#### Download notifications

```
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
        reak
    case .failed:
        DYFStoreLog("The download failed")
        break
    case .succeeded:
        DYFStoreLog("The download succeeded: 100%%")
        break
    }
}
```


### Receipt verification

`DYFStore` doesn't perform receipt verification by default, but provides reference implementations. You can implement your own custom verification or use the reference verifier provided by the library.

The reference verifier is outlined below. For more info, check out the [wiki](https://github.com/dgynfi/DYFStore/wiki/Receipt-verification).

#### Reference verifier

You create and return a receipt verifier(`DYFStoreReceiptVerifier`) by using lazy loading.

```
lazy var receiptVerifier: DYFStoreReceiptVerifier = {
    let verifier = DYFStoreReceiptVerifier()
    verifier.delegate = self
    return verifier
}()
```

The receipt verifier delegates receipt verification, enabling you to provide your own implementation using the `DYFStoreReceiptVerifierDelegate` protocol:

```
@objc func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any])

@objc func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError)
```

You can start verifying the in-app purchase receipt. 

```
// Fetches the data of the bundle’s App Store receipt. 
let data = receiptData

self.receiptVerifier.verifyReceipt(data)

// Only used for receipts that contain auto-renewable subscriptions.
//self.receiptVerifier.verifyReceipt(data, sharedSecret: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

If security is a concern you might want to avoid using an open source verification logic, and provide your own custom verifier instead.

It is better to use your own server with the parameters that was uploaded from the client to verify the receipt from the apple itunes store server (C -> Uploaded Parameters -> S -> Apple iTunes Store S -> S -> Receive Data -> C, C: client, S: server).


### Finish transactions

The transaction can be finished only after the receipt verification passed under the client and the server can adopt the communication of security and data encryption. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction.

```
DYFStore.default.finishTransaction(transaction)
```


## Transaction persistence

`DYFStore` provides two optional reference implementations for storing transactions in the Keychain(`DYFStoreKeychainPersistence`) or in `NSUserDefaults`(`DYFStoreUserDefaultsPersistence`). 

For example:

### Store transaction

```
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
```

### Remove transaction

```
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
        store.finishTransaction(transaction)
    }

    persister.removeTransaction(identifier)
}
```


## Requirements

`DYFStore` requires `iOS 8.0` or above and `ARC`.
