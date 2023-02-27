## DYFStore

A lightweight and easy-to-use iOS library for In-App Purchases. (Swift)

`DYFStore` uses blocks and [notifications](#Notifications) to wrap `StoreKit`, provides [receipt verification](#Receipt-verification) and [transaction persistence](#Transaction-persistence). 

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/DYFStore.svg?style=flat)](http://cocoapods.org/pods/DYFStore)&nbsp;
![CocoaPods](http://img.shields.io/cocoapods/p/DYFStore.svg?style=flat)&nbsp;

[Chinese Instructions (中文说明)](README-zh.md)


## Related Links

- [DYFSwiftRuntimeProvider](https://github.com/chenxing640/DYFSwiftRuntimeProvider/)
- [DYFSwiftKeychain](https://github.com/chenxing640/DYFSwiftKeychain/)
- [DYFStoreReceiptVerifier_Swift](https://github.com/chenxing640/DYFStoreReceiptVerifier_Swift/)
- [Unity-iOS-InAppPurchase](https://github.com/chenxing640/Unity-iOS-InAppPurchase/)
- [in-app-purchase-complete-programming-guide-for-iOS](https://chenxing640.github.io/2016/10/16/in-app-purchase-complete-programming-guide-for-iOS/)
- [how-to-easily-complete-in-app-purchase-configuration-for-iOS](https://chenxing640.github.io/2016/10/12/how-to-easily-complete-in-app-purchase-configuration-for-iOS/)


## Features

- Super simple in-app purchases.
- Built-in support for remembering your purchases.
- Built-in receipt validation (remote).
- Built-in hosted content downloads and notifications.


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/chenxing640/DYFStore/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFStore'
or
pod 'DYFStore', '~> 2.0.2'
```

Check out the [wiki](https://github.com/chenxing640/DYFStore/wiki/Installation) for more options.


## Usage

Next I'll show you how to use `DYFStore`.

### Initialization

The initialization is as follows.

- Whether to allow the logs output to the console, set 'true' in debug mode, view the logs of the whole process of in-app purchase, and set 'false' when publishing app in release mode.
- Adds the observer of transactions and monitors the change of transactions.
- Instantiates data persistent object and stores the related information of transactions.
- Follows the agreement `DYFStoreAppStorePaymentDelegate` and processes payments for products purchased from the App Store.

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    self.initIAPSDK()

    return true
}

func initIAPSDK() {
    DYFStoreManager.shared.addStoreObserver()
    
    // Wether to allow the logs output to console.
    DYFStore.default.enableLog = true
    
    // Adds an observer that responds to updated transactions to the payment queue.
    // If an application quits when transactions are still being processed, those transactions are not lost. The next time the application launches, the payment queue will resume processing the transactions. Your application should always expect to be notified of completed transactions.
    // If more than one transaction observer is attached to the payment queue, no guarantees are made as to the order they will be called in. It is recommended that you use a single observer to process and finish the transaction.
    DYFStore.default.addPaymentTransactionObserver()
    
    // Sets the delegate processes the purchase which was initiated by user from the App Store.
    DYFStore.default.delegate = self
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
    let userIdentifier = DYFStore_supplySHA256(accountName) ?? ""
    DYFStoreLog("userIdentifier: \(userIdentifier)")
    DYFStoreManager.shared.addPayment(product.productIdentifier, userIdentifier: userIdentifier)
}
```


### Request products

You need to check whether the device is not able or allowed to make payments before requesting products.

```
if !DYFStore.canMakePayments() {
    self.showTipsMessage("Your device is not able or allowed to make payments!")
    return
}
```

To begin the purchase process, your app must know its product identifiers. There are two strategies for retrieving information about the products from the App Store.

**Strategy 1:** Your app can uses a product identifier to fetch information about product available for sale in the App Store and to submit payment request directly.

```
@IBAction func fetchesProductAndSubmitsPayment(_ sender: Any) {
    // You need to check whether the device is not able or allowed to make payments before requesting product.
    if !DYFStore.canMakePayments() {
        self.showTipsMessage("Your device is not able or allowed to make payments!")
        return
    }
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
    let userIdentifier = DYFStore_supplySHA256(accountName) ?? ""
    DYFStoreLog("userIdentifier: \(userIdentifier)")
    DYFStoreManager.shared.addPayment(productId, userIdentifier: userIdentifier)
}
```

**Strategy 2:** It can retrieve information about the products from the App Store and present its store UI to the user. Every product sold in your app has a unique product identifier. Your app uses these product identifiers to fetch information about products available for sale in the App Store, such as pricing, and to submit payment requests when users purchase those products.

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
    // You need to check whether the device is not able or allowed to make payments before requesting products.
    if !DYFStore.canMakePayments() {
        self.showTipsMessage("Your device is not able or allowed to make payments!")
        return
    }
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
    let storeVC = DYFStoreViewController()
    storeVC.dataArray = dataArray
    self.navigationController?.pushViewController(storeVC, animated: true)
}
```


### Add payment

Requests payment of the product with the given product identifier.

```
DYFStore.default.purchaseProduct("com.hncs.szj.coin210")
```

If you need an opaque identifier for the user’s account on your system to add payment, you can use a one-way hash of the user’s account name to calculate the value for this property.

Calculates the SHA256 hash function:

```
public func DYFStore_supplySHA256(_ s: String) -> String? {
    guard let cStr = s.cString(using: String.Encoding.utf8) else {
        return nil
    }
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH) // 32
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

Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.

```
DYFStore.default.purchaseProduct("com.hncs.szj.coin210", userIdentifier: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```


### Restore transactions

- Restores transactions without the user account identifier.

```
DYFStore.default.restoreTransactions()
```

- Restores transactions with the user account identifier.

```
DYFStore.default.restoreTransactions(userIdentifier: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```


### Refresh receipt

If `Bundle.main.appStoreReceiptURL` is null, you need to create a refresh receipt request to obtain a receipt for a payment transaction.

```
DYFStore.default.refreshReceipt(onSuccess: {
    self.storeReceipt()
}) { (error) in
    self.failToRefreshReceipt()
}
```


### Notifications

`DYFStore` sends notifications of `StoreKit` related events and extends `NSNotification` to provide relevant information. To receive them, add the observer to a `DYFStore` manager.

#### Add the store observer

```
func addStoreObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processPurchaseNotification(_:)), name: DYFStore.purchasedNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processDownloadNotification(_:)), name: DYFStore.downloadedNotification, object: nil)
}
```

#### Remove the store observer

When the application exits, you need to remove the store observer.

```
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
        break
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

The reference verifier is outlined below. For more info, check out the [wiki](https://github.com/chenxing640/DYFStore/wiki/Receipt-verification).

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
public func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any]) {}

public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {}
```

You can start verifying the in-app purchase receipt. 

```
// Fetches the data of the bundle’s App Store receipt. 
let data = receiptData
or
let data = try? Data(contentsOf: DYFStore.receiptURL())

self.receiptVerifier.verifyReceipt(data)

// Only used for receipts that contain auto-renewable subscriptions.
//self.receiptVerifier.verifyReceipt(data, sharedSecret: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

If security is a concern you might want to avoid using an open source verification logic, and provide your own custom verifier instead.

It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C, C: client, S: server).


### Finish transactions

The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.

```
DYFStore.default.finishTransaction(transaction)
```


## Transaction persistence

`DYFStore` provides an optional reference implementation for storing transactions in `NSUserDefaults`(`DYFStoreUserDefaultsPersistence`). 

When the client crashes during the payment process, it is particularly important to store transaction information. When storekit notifies the uncompleted payment again, it takes the data directly from keychain and performs the receipt verification until the transaction is completed.

### Store transaction

```
func storeReceipt() {
    guard let url = DYFStore.receiptURL() else {
        self.refreshReceipt()
        return
    }
    do {
        let data = try Data(contentsOf: url)
        let info = self.purchaseInfo!
        let persister =  DYFStoreUserDefaultsPersistence()
        
        let transaction = DYFStoreTransaction()
        if info.state! == .succeeded {
            transaction.state = DYFStoreTransactionState.purchased.rawValue
        } else if info.state! == .restored {
            transaction.state = DYFStoreTransactionState.restored.rawValue
        }
        
        transaction.productIdentifier = info.productIdentifier
        transaction.userIdentifier = info.userIdentifier
        transaction.transactionTimestamp = info.transactionDate?.timestamp()
        transaction.transactionIdentifier = info.transactionIdentifier
        transaction.originalTransactionTimestamp = info.originalTransactionDate?.timestamp()
        transaction.originalTransactionIdentifier = info.originalTransactionIdentifier
        
        transaction.transactionReceipt = data.base64EncodedString()
        persister.storeTransaction(transaction)
        
        self.verifyReceipt(data)
    } catch let error {
        DYFStoreLog("error: \(error.localizedDescription)")
        self.refreshReceipt()
        return
    }
}
```

### Remove transaction

```
let info = self.purchaseInfo!
let store = DYFStore.default
let persister = DYFStoreUserDefaultsPersistence()
let identifier = info.transactionIdentifier!

if info.state! == .restored {
    let transaction = store.extractRestoredTransaction(identifier)
    store.finishTransaction(transaction)
} else {
    let transaction = store.extractPurchasedTransaction(identifier)
    // The transaction can be finished only after the receipt verification passed under the client and the server can adopt the communication of security and data encryption. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction.
    store.finishTransaction(transaction)
}

persister.removeTransaction(identifier)

if let id = info.originalTransactionIdentifier {
    persister.removeTransaction(id)
}
```


## Requirements

`DYFStore` requires `iOS 8.0` or above and `ARC`.


## Demo

To learn more, please clone this project (`git clone https://github.com/chenxing640/DYFStore.git`) to the local directory.


## Feedback is welcome

If you notice any issue, got stuck to create an issue. I will be happy to help you.
