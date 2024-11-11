//
//  SKStoreViewController.swift
//
//  Created by Tenfay on 2016/11/28.
//  Copyright © 2016 Tenfay. All rights reserved.
//

import UIKit

class SKStoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var storeTableView: UITableView!
    
    public var dataArray: [SKStoreProduct]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Store", tableName: nil, comment: "")
        self.addRightBarButtonItem()
    }
    
    func addRightBarButtonItem() {
        let item = UIBarButtonItem(title: "Restore", style: UIBarButtonItem.Style.plain, target: self, action: #selector(restore))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc func restore() {
        // Get account name from your own user system.
        let accountName = "Handsome Jon"
        // This algorithm is negotiated with server developer.
        let userIdentifier = accountName.tx_sha256 ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        SKIAPManager.shared.restorePurchases(userIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "StoreTableViewCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SKStoreTableViewCell
        if cell == nil {
            let nib = UINib(nibName: "SKStoreTableViewCell", bundle: nil)
            let objects = nib.instantiate(withOwner: nil, options: nil)
            cell = objects[0] as? SKStoreTableViewCell
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
        let userIdentifier = accountName.tx_sha256 ?? ""
        DYFStoreLog("userIdentifier: \(userIdentifier)")
        SKIAPManager.shared.addPayment(productIdentifier, userIdentifier: userIdentifier)
    }
    
}
