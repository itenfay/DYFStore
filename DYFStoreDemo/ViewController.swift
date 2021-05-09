//
//  ViewController.swift
//
//  Created by dyf on 2016/11/28. ( https://github.com/dgynfi/DYFStore )
//  Copyright © 2016 dyf. All rights reserved.
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
        self.fetchesProductAndSubmitsPaymentButton.setCorner(radius: 20.0)
        self.fetchesProductsAndDisplaysStoreUIButton.setCorner(radius: 20.0)
    }
    
    /// Strategy 1:
    ///  - Step 1: Requests localized information about a product from the Apple App Store.
    ///  - Step 2: Adds payment of a product with its product identifier.
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
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        
        DYFStoreManager.shared.addPayment(productId, userIdentifier: userIdentifier)
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
    
    /// Strategy 2:
    ///  - Step 1: Requests localized information about a set of products from the Apple App Store.
    ///  - Step 2: After retrieving the localized product list, then display store UI.
    ///  - Step 3: Adds payment of a product with its product identifier.
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
    
    func sendNotice(_ message: String) {
        self.showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                       message: message,
                       cancelButtonTitle: nil,
                       cancel: nil,
                       confirmButtonTitle: NSLocalizedString("I see!", tableName: nil, comment: ""))
        { (action) in
            DYFStoreLog("alert action title: \(action.title!)")
        }
    }
    
}
