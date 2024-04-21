//
//  ViewController.swift
//
//  Created by Teng Fei on 2016/11/28.
//  Copyright © 2016 Teng Fei. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var fetchesProductAndSubmitsPaymentButton: UIButton!
    @IBOutlet weak var fetchesProductsAndDisplaysStoreUIButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("In-app Purchase", tableName: nil, comment: "")
        self.configure()
    }
    
    private func configure() {
        self.fetchesProductAndSubmitsPaymentButton.sk_setCorner(radius: 20.0)
        self.fetchesProductsAndDisplaysStoreUIButton.sk_setCorner(radius: 20.0)
    }
    
    /// Strategy 1:
    ///  - Step 1: Requests localized information about a product from the Apple App Store.
    ///  - Step 2: Adds payment of a product with its product identifier.
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
                // Test
                //self.displayStoreUI(self.getSampleProducts())
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
        let userIdentifier = DYFStoreCryptoSHA256(accountName) ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        SKIAPManager.shared.addPayment(productId, userIdentifier: userIdentifier)
    }
    
    /// Strategy 2:
    ///  - Step 1: Requests localized information about a set of products from the Apple App Store.
    ///  - Step 2: After retrieving the localized product list, then display store UI.
    ///  - Step 3: Adds payment of a product with its product identifier.
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
        let storeVC = SKStoreViewController()
        storeVC.dataArray = dataArray
        self.navigationController?.pushViewController(storeVC, animated: true)
    }
    
    func sendNotice(_ message: String) {
        self.sk_showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                          message: message,
                          cancelButtonTitle: nil,
                          cancel: nil,
                          confirmButtonTitle: NSLocalizedString("I see!", tableName: nil, comment: ""))
        { (action) in
            DYFStoreLog("alert action title: \(action.title!)")
        }
    }
    
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
    
    func getSampleProducts() -> [SKStoreProduct] {
        var prodArray: [SKStoreProduct] = []
        let p1 = SKStoreProduct()
        p1.identifier = "com.hncs.szj.coin42"
        p1.name = "42 gold coins"
        p1.price = "￥6"
        p1.localePrice = "---"
        p1.localizedDescription = "42 gold coins for ￥6"
        prodArray.append(p1)
        
        let p2 = SKStoreProduct()
        p2.identifier = "com.hncs.szj.coin210"
        p2.name = "210 gold coins"
        p2.price = "￥30"
        p2.localePrice = "---"
        p2.localizedDescription = "210 gold coins for ￥30"
        prodArray.append(p2)
        
        let p3 = SKStoreProduct()
        p3.identifier = "com.hncs.szj.coin686"
        p3.name = "686 gold coins"
        p3.price = "￥98"
        p3.localePrice = "---"
        p3.localizedDescription = "686 gold coins for ￥98"
        prodArray.append(p3)
        
        let p4 = SKStoreProduct()
        p4.identifier = "com.hncs.szj.coin1386"
        p4.name = "1386 gold coins"
        p4.price = "￥198"
        p4.localePrice = "---"
        p4.localizedDescription = "1386 gold coins for ￥198"
        prodArray.append(p4)
        
        let p5 = SKStoreProduct()
        p5.identifier = "com.hncs.szj.coin4886"
        p5.name = "4886 gold coins"
        p5.price = "￥698"
        p5.localePrice = "---"
        p5.localizedDescription = "4886 gold coins for ￥698"
        prodArray.append(p5)
        
        let p6 = SKStoreProduct()
        p6.identifier = "com.hncs.szj.vip1"
        p6.name = "VIP1"
        p6.price = "￥299"
        p6.localePrice = "---"
        p6.localizedDescription = "Non-renewable vip subscription for a month"
        prodArray.append(p6)
        
        let p7 = SKStoreProduct()
        p7.identifier = "com.hncs.szj.vip2"
        p7.name = "VIP2"
        p7.price = "￥699"
        p7.localePrice = "---"
        p7.localizedDescription = "Auto-renewable vip subscription for three months"
        prodArray.append(p7)
        return prodArray
    }
    
}
