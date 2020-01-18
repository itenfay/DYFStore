//
//  ViewController.swift
//
//  Created by dyf on 2016/11/28.
//  Copyright © 2016 dyf. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var fetchProductsButton: UIButton!
    @IBOutlet weak var presentStoreUIButton: UIButton!
    
    private var availableProducts = [DYFStoreProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("In-app Purchase", tableName: nil, comment: "")
        self.initializeAndConfigure()
    }
    
    private func initializeAndConfigure() {
        self.fetchProductsButton.setCorner(radius: 20.0)
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
    
    @IBAction func fetchProductsFromAppStore(_ sender: Any) {
        
        self.showLoading("Loading...")
        
        let productIds = fetchProductIdentifiersFromServer()
        DYFStore.default.requestProduct(withIdentifiers: productIds, success: { (products, invalidIdentifiers) in
            
            self.hideLoading()
            
            for product in products {
                if self.hasProduct(product.productIdentifier) {
                    let p = DYFStoreProduct()
                    p.identifier = product.productIdentifier
                    p.name = product.localizedTitle
                    p.price = product.price.stringValue
                    p.localePrice = DYFStore.default.localizedPrice(ofProduct: product)
                    p.localizedDescription = product.localizedDescription
                    self.availableProducts.append(p)
                }
            }
            
            DYFStoreLog("invalidIdentifiers: \(invalidIdentifiers)")
            
        }) { (error) in
            
            self.hideLoading()
            self.sendNotice("An error occurs, \(error.code), \(error.localizedDescription).")
        }
    }
    
    @IBAction func presentStoreUI(_ sender: Any) {
        
        if !DYFStore.canMakePayments() {
            DYFStoreManager.shared.showTipsMessage("Your device is not able or allowed to make payments!")
            return
        }
        
        let products = self.availableProducts
        presentStoreUI(withProducts: products)
    }
    
    func presentStoreUI(withProducts products: [DYFStoreProduct]) {
        
        guard products.count > 0 else {
            DYFStoreManager.shared.showTipsMessage("There are no products for sale!")
            return
        }
        
        let svc = DYFStoreViewController()
        svc.dataArray = NSArray(array: self.availableProducts) as? [DYFStoreProduct]
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
        
        for item in self.availableProducts {
            
            if let id = item.identifier, id == productIdentifier {
                return true
            }
        }
        return false
    }
    
}
