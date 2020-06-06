//
//  DDYFStoreViewController.swift
//
//  Created by dyf on 2016/11/28. ( https://github.com/dgynfi/DYFStore )
//  Copyright © 2016 dyf. All rights reserved.
//

import UIKit

class DYFStoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var storeTableView: UITableView!
    
    public var dataArray: [DYFStoreProduct]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Store", tableName: nil, comment: "")
        self.addRightBarButtonItem()
    }
    
    func addRightBarButtonItem() {
        let item = UIBarButtonItem(title: "Restore", style: UIBarButtonItem.Style.plain, target: self, action: #selector(DYFStoreViewController.restore))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc func restore() {
        
        // Get account name from your own user system.
        let accountName = "Handsome Jon"
        
        // This algorithm is negotiated with server developer.
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        
        DYFStoreManager.shared.restorePurchases(userIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "StoreTableViewCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DYFStoreTableViewCell
        if cell == nil {
            let nib = UINib(nibName: "DYFStoreTableViewCell", bundle: nil)
            let objects = nib.instantiate(withOwner: nil, options: nil)
            cell = objects[0] as? DYFStoreTableViewCell
        }
        
        let product = self.dataArray![indexPath.row]
        cell!.nameLabel.text = product.name
        cell!.localePriceLabel.text = product.localePrice
        
        cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let product = self.dataArray![indexPath.row]
        let productIdentifier = product.identifier!
        DYFStoreLog("productIdentifier: \(productIdentifier)")
        
        // Get account name from your own user system.
        let accountName = "Handsome Jon"
        
        // This algorithm is negotiated with server developer.
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        
        DYFStoreManager.shared.addPayment(productIdentifier, userIdentifier: userIdentifier)
    }
    
}
