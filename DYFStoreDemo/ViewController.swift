//
//  ViewController.swift
//
//  Created by dyf on 2016/11/28. ( https://github.com/dgynfi/DYFStore )
//  Copyright © 2016 dyf. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var buyAProductButton   : UIButton!
    @IBOutlet weak var fetchProductsButton : UIButton!
    @IBOutlet weak var presentStoreUIButton: UIButton!
    
    private var productArrayToDisplay = [DYFStoreProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("In-app Purchase", tableName: nil, comment: "")
        self.configure()
    }
    
    private func configure() {
        self.buyAProductButton.setCorner   (radius: 20.0)
        self.fetchProductsButton.setCorner (radius: 20.0)
        self.presentStoreUIButton.setCorner(radius: 20.0)
    }
    
    func fetchProductIdentifiersFromServer() -> [String] {
        
        let productIds = [
            "com.hncs.szj.coin48",   // 42 gold coins for ￥6.
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
    
    /// Mode 1:
    ///  - Step 1: Requests localized information about a product identifier from the Apple App Store.
    ///  - Step 2: Adds payment of the product with the given product identifier.
    @IBAction func buyASingleProductAndPay(_ sender: Any) {
        self.showLoading("Loading...")
        
        let productID = "com.hncs.szj.coin48"
        
        DYFStore.default.requestProduct(withIdentifier: productID, success: { (products, invalidIdentifiers) in
            
            self.hideLoading()
            
            if products.count == 1 {
                
                let productID = products[0].productIdentifier
                self.addPayment(productID)
                
            } else {
                
                self.showTipsMessage("There is no this product for sale!")
            }
            
            DYFStoreLog("invalidIdentifiers: \(invalidIdentifiers)")
            
        }) { (error) in
            
            self.hideLoading()
            self.sendNotice("An error occurs, \(error.code), \(error.localizedDescription).")
        }
    }
    
    private func addPayment(_ productID: String) {
        // Get account name from your own user system.
        let accountName = "Handsome Jon"
        
        // This algorithm is negotiated with server developer.
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        
        DYFStoreManager.shared.addPayment(productID, userIdentifier: userIdentifier)
    }
    
    /// Mode 2:
    ///  - Step 1: Requests localized information about a set of products from the Apple App Store.
    ///  - Step 2: After obtaining the localized product list, then display the purchase product panel at the right time.
    ///  - Step 3: Adds payment of the product with the given product identifier.
    @IBAction func fetchProductsFromAppStore(_ sender: Any) {
        self.showLoading("Loading...")
        
        let productIds = fetchProductIdentifiersFromServer()
        DYFStore.default.requestProduct(withIdentifiers: productIds, success: { (products, invalidIdentifiers) in
            
            self.hideLoading()
            
            if products.count > 0 {
                
                self.getData(products)
                
            } else if products.count == 0 &&
                invalidIdentifiers.count > 0 {
                
                DYFStoreLog("Please check the product information you set up.")
            }
            
            DYFStoreLog("invalidIdentifiers: \(invalidIdentifiers)")
            
        }) { (error) in
            
            self.hideLoading()
            self.sendNotice("An error occurs, \(error.code), \(error.localizedDescription).")
        }
    }
    
    private func getData(_ products: [SKProduct]) {
        
        for product in products {
            
            if self.hasProduct(product.productIdentifier) {
                
                let p = DYFStoreProduct()
                p.identifier = product.productIdentifier
                p.name = product.localizedTitle
                p.price = product.price.stringValue
                p.localePrice = DYFStore.default.localizedPrice(ofProduct: product)
                p.localizedDescription = product.localizedDescription
                
                self.productArrayToDisplay.append(p)
            }
        }
    }
    
    @IBAction func presentStoreUI(_ sender: Any) {
        
        if !DYFStore.canMakePayments() {
            self.showTipsMessage("Your device is not able or allowed to make payments!")
            return
        }
        
        let products = self.productArrayToDisplay
        presentStoreUI(withProducts: products)
    }
    
    func presentStoreUI(withProducts products: [DYFStoreProduct]) {
        
        guard products.count > 0 else {
            self.showTipsMessage("There are no products for sale!")
            return
        }
        
        let svc = DYFStoreViewController()
        svc.dataArray = NSArray(array: self.productArrayToDisplay) as? [DYFStoreProduct]
        self.navigationController?.pushViewController(svc, animated: true)
    }
    
    public func sendNotice(_ message: String) {
        self.showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                       message: message,
                       cancelButtonTitle: nil,
                       cancel: nil,
                       confirmButtonTitle: NSLocalizedString("I see!", tableName: nil, comment: ""))
        { (action) in
            DYFStoreLog("alert action title: \(action.title!)")
        }
    }
    
    func hasProduct(_ productIdentifier: String) -> Bool {
        
        for item in self.productArrayToDisplay {
            
            if let id = item.identifier, id == productIdentifier {
                return true
            }
        }
        
        return false
    }
    
}
