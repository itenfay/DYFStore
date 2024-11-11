**中文版** | [English Version](README-en.md)


## DYFStore

一个轻量级且易于使用的iOS应用内购库([Objective-C Version](https://github.com/itenfay/DYFStoreKit))。

`DYFStore`使用代码块和[通知](#通知)包装`StoreKit`，提供[收据验证](#收据验证)和[交易持久化](#交易持久化)。

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/DYFStore.svg?style=flat)](http://cocoapods.org/pods/DYFStore)&nbsp;
![CocoaPods](http://img.shields.io/cocoapods/p/DYFStore.svg?style=flat)&nbsp;


## 相关连接

- [DYFSwiftRuntimeProvider](https://github.com/itenfay/DYFSwiftRuntimeProvider/)
- [DYFSwiftKeychain](https://github.com/itenfay/DYFSwiftKeychain/)
- [DYFStoreReceiptVerifier_Swift](https://github.com/itenfay/DYFStoreReceiptVerifier_Swift/)
- [Unity-iOS-InAppPurchase](https://github.com/itenfay/Unity-iOS-InAppPurchase/)
- [in-app-purchase-complete-programming-guide-for-iOS](https://itenfay.github.io/2016/10/16/in-app-purchase-complete-programming-guide-for-iOS/)
- [how-to-easily-complete-in-app-purchase-configuration-for-iOS](https://itenfay.github.io/2016/10/12/how-to-easily-complete-in-app-purchase-configuration-for-iOS/)


## 特点

- 超级简单的应用内购买
- 内置支持记住您的购买
- 内置收据验证（远程）
- 内置托管内容下载和通知


## QQ群 (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/itenfay/DYFStore/raw/master/images/g614799921.jpg" width="30%" />
</div>


## 安装

使用 [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFStore'
```

Or

```
pod 'DYFStore', '~> 2.3.0'
```

查看 [wiki](https://github.com/itenfay/DYFStore/wiki/Installation) 以获取更多选项。


## 使用

接下来我会教你如何使用 `DYFStore`。

### 初始化

初始化如下所示。

- 是否允许将日志输出到控制台，在 Debug 模式下设置 `true`，查看内购整个过程的日志，在 Release 模式下发布 App 时将 enableLog 设置 `false`。
- 添加交易的观察者，监听交易的变化。
- 实例化数据持久，存储交易的相关信息。
- 遵守协议 `DYFStoreAppStorePaymentDelegate`，处理从 App Store 购买产品的付款。

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    self.initIAPSDK()

    return true
}

func initIAPSDK() {
    SKIAPManager.shared.addStoreObserver()
    
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

你可以处理用户从应用商店发起的购买，并使用 `DYFStoreAppStorePaymentDelegate` 协议提供自己的实现：

```
// Processes the purchase which was initiated by user from the App Store.
func didReceiveAppStorePurchaseRequest(_ queue: SKPaymentQueue, payment: SKPayment, forProduct product: SKProduct) -> Bool {
    if !DYFStore.canMakePayments() {
        self.sk_showTipsMessage("Your device is not able or allowed to make payments!")
        return false
    }
    
    // Get account name from your own user system.
    let accountName = "Handsome Jon"
    // This algorithm is negotiated with server developer.
    let userIdentifier = accountName.tx_sha256 ?? ""
    DYFStoreLog("userIdentifier: \(userIdentifier)")
    SKIAPManager.shared.addPayment(product.productIdentifier, userIdentifier: userIdentifier)
    return true
}
```

### 创建商品查询的请求

在创建商品查询的请求前，你需要检查设备是否能够或者被允许付款。

```
if !DYFStore.canMakePayments() {
    self.sk_showTipsMessage("Your device is not able or allowed to make payments!")
    return
}
```

在开始购买过程，首先必须清楚有哪些产品标识符。有两种策略可用于从应用程序商店获取有关产品的信息。

**策略1：** App 可以使用其中一个产品标识符来获取应用程序商店中可供销售的产品的信息，并直接提交付款请求。

```
@IBAction func fetchesProductAndSubmitsPayment(_ sender: Any) {
    // You need to check whether the device is not able or allowed to make payments before requesting product.
    if !DYFStore.canMakePayments() {
        self.sk_showTipsMessage("Your device is not able or allowed to make payments!")
        return
    }
    self.sk_showLoading("Loading...")
    
    let productId = "com.hncs.szj.coin42"
    DYFStore.default.requestProduct(withIdentifier: productId, success: { (products, invalidIdentifiers) in
        self.sk_hideLoading()
        if products.count == 1 {
            let productId = products[0].productIdentifier
            self.addPayment(productId)
        } else {
            self.sk_showTipsMessage("There is no this product for sale!")
        }
    }) { (error) in
        self.sk_hideLoading()
        let value = error.userInfo[NSLocalizedDescriptionKey] as? String
        let msg = value ?? "\(error.localizedDescription)"
        self.sendNotice("An error occurs, \(error.code), " + msg)
    }
}

private func addPayment(_ productId: String) {
    // Get account name from your own user system.
    let accountName = "Handsome Jon"
    // This algorithm is negotiated with server developer.
    let userIdentifier = accountName.tx_sha256 ?? ""
    DYFStoreLog("userIdentifier: \(userIdentifier)")
    SKIAPManager.shared.addPayment(productId, userIdentifier: userIdentifier)
}
```

**策略2：** App 从应用程序商店获取有关产品的信息，并向用户显示其商店用户界面。App 中销售的每个产品都有唯一的产品标识符。App 使用这些产品标识符获取有关应用程序商店中可供销售的产品的信息，例如定价，并在用户购买这些产品时提交付款请求。

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
        self.sk_showTipsMessage("Your device is not able or allowed to make payments!")
        return
    }
    self.sk_showLoading("Loading...")
    
    let productIds = fetchProductIdentifiersFromServer()
    DYFStore.default.requestProduct(withIdentifiers: productIds, success: { (products, invalidIdentifiers) in
        self.sk_hideLoading()
        if products.count > 0 {
            self.processData(products)
        } else if products.count == 0 &&
                    invalidIdentifiers.count > 0 {
            // Please check the product information you set up.
            self.sk_showTipsMessage("There are no products for sale!")
        }
    }) { (error) in
        self.sk_hideLoading()
        let value = error.userInfo[NSLocalizedDescriptionKey] as? String
        let msg = value ?? "\(error.localizedDescription)"
        self.sendNotice("An error occurs, \(error.code), " + msg)
    }
}

private func processData(_ products: [SKProduct]) {
    var modelArray = [SKStoreProduct]()
    for product in products {
        let p = SKStoreProduct()
        p.identifier = product.productIdentifier
        p.name = product.localizedTitle
        p.price = product.price.stringValue
        p.localePrice = DYFStore.default.localizedPrice(ofProduct: product)
        p.localizedDescription = product.localizedDescription
        modelArray.append(p)
    }
    self.displayStoreUI(modelArray)
}

private func displayStoreUI(_ dataArray: [SKStoreProduct]) {
    let storeVC = DYFStoreViewController()
    storeVC.dataArray = dataArray
    self.navigationController?.pushViewController(storeVC, animated: true)
}
```

### 创建购买产品的付款请求

使用给定的产品标识符请求产品付款。

```
DYFStore.default.purchaseProduct("com.hncs.szj.coin210")
```

如果需要系统上用户帐户的不透明标识符来添加付款，可以使用用户帐户名的单向哈希来计算此属性的值。

计算 SHA256 哈希值函数：

```
extension String {
    /// Custom method to calculate the SHA-256 hash using Common Crypto.
    ///
    /// - Parameter s: A string to calculate hash.
    /// - Returns: A SHA-256 hash value string.
    public var tx_sha256 : String? {
        guard let cStr = cString(using: String.Encoding.utf8) else {
            return nil
        }
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH) // 32
        let cStrLen = Int(lengthOfBytes(using: String.Encoding.utf8))
        
        // Confirm that the length of C string is small enough
        // to be recast when calling the hash function.
        if cStrLen > UINT32_MAX {
            print("C string too long to hash: \(self)")
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
}
```

使用给定的产品标识符和系统中用户帐户的不透明标识符请求产品付款。

```
DYFStore.default.purchaseProduct("com.hncs.szj.coin210", userIdentifier: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

### 恢复已购买的付款交易

在某些场景（如切换设备），App 需要提供恢复购买按钮，用来恢复之前购买的非消耗型的产品。

- 无绑定用户帐户 ID 的恢复

```
DYFStore.default.restoreTransactions()
```

- 绑定用户帐户 ID 的恢复

```
DYFStore.default.restoreTransactions(userIdentifier: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

### 创建刷新收据请求

如果 `Bundle.main.appStoreReceiptURL` 为空，就需要创建刷新收据请求，获取付款交易的收据。

```
DYFStore.default.refreshReceipt(onSuccess: {
    self.storeReceipt()
}) { (error) in
    self.failToRefreshReceipt()
}
```

### 通知

`DYFStore`发送与`StoreKit`相关事件的通知，并扩展`NSNotification`以提供相关信息。要接收它们，请将观察者添加到`DYFStore`管理员。

#### 添加商店观察者，监听购买和下载通知

```
func addStoreObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(processPurchaseNotification(_:)), name: DYFStore.purchasedNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(processDownloadNotification(_:)), name: DYFStore.downloadedNotification, object: nil)
}
```

#### 在适当的时候，移除商店观察者

```
func removeStoreObserver() {
    NotificationCenter.default.removeObserver(self, name: DYFStore.purchasedNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: DYFStore.downloadedNotification, object: nil)
}
```

#### 付款交易的通知处理

付款交易的通知是在请求付款后发送的，或是为每个恢复的交易发送的。

```
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
```

#### 下载的通知处理

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

### 收据验证

`DYFStore`默认情况下不执行收据验证，但提供引用实现。您可以实现自己的自定义验证或使用库提供的引用验证程序。

引用验证程序概述如下。有关更多信息，请查看 [wiki](https://github.com/itenfay/DYFStore/wiki/Receipt-verification)。

#### 引用验证器

通过使用延迟加载创建并返回收据验证器（`DYFStoreReceiptVerifier`）。

```
lazy var receiptVerifier: DYFStoreReceiptVerifier = {
    let verifier = DYFStoreReceiptVerifier()
    verifier.delegate = self
    return verifier
}()
```

收据验证程序委托收据验证，使您能够使用`DYFStoreReceiptVerifierDelegate`协议提供自己的实现：

```
public func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any]) {}
public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {}
```

你可以开始验证应用内购买收据。

```
// Fetches the data of the bundle’s App Store receipt. 
let data = receiptData
or
let data = try? Data(contentsOf: DYFStore.receiptURL())

self.receiptVerifier.verifyReceipt(data)

// Only used for receipts that contain auto-renewable subscriptions.
self.receiptVerifier.verifyReceipt(data, sharedSecret: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

如果担心安全性，你可能希望避免使用开源验证逻辑，提供自己的自定义验证程序。

最好使用你自己的服务器获取从客户端上传的参数，以验证来自App Store服务器的收据的响应信息（C -> 上传的参数 -> S -> App Store S -> S -> 接收并解析数据 -> C，C：客户端，S：服务器）。

### 完成交易

只有客户机与服务器采用安全通信和数据加密并且收据验证通过后，才能完成交易。这样，我们可以避免刷新订单和破解应用内购买。如果我们无法完成验证，我们希望`StoreKit`不断提醒我们还有未完成的交易。

```
DYFStore.default.finishTransaction(transaction)
```


## 交易持久化

`DYFStore`提供了一个可选的引用实现，用于将交易信息存储在 NSUserDefaults（`DYFStoreUserDefaultsPersistence`）中。

当客户端在付款过程中发生崩溃，导致 App 闪退，这时存储交易信息尤为重要。当 StoreKit 再次通知未完成的付款时，直接从文件中取出数据，进行收据验证，直至完成交易。

### 存储交易信息

```
func storeReceipt() {
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
```

### 移除交易信息

```
let info = self.purchaseInfo!
let store = DYFStore.default
let persister = DYFStoreUserDefaultsPersistence()
let identifier = info.transactionIdentifier!

if info.state! == .restored {
    let tx = store.extractRestoredTransaction(identifier)
    store.finishTransaction(tx)
} else {
    let tx = store.extractPurchasedTransaction(identifier)
    // The transaction can be finished only after the receipt verification passed under the client and the server can adopt the communication of security and data encryption. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction.
    store.finishTransaction(tx)
}

persister.removeTransaction(identifier)

if let id = info.originalTransactionIdentifier {
    persister.removeTransaction(id)
}
```


## 要求

`DYFStore`需要`iOS 8.0`或更高版本和ARC。


## 演示

如需了解更多，请克隆此项目（`git clone https://github.com/itenfay/DYFStore.git`）到本地目录。


## 欢迎反馈

如果您发现任何问题，请创建问题。我很乐意帮助你。
