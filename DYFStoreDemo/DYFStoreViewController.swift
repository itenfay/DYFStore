//
//  DDYFStoreViewController.swift
//
//  Created by dyf on 2016/11/28.
//  Copyright © 2016 dyf. ( https://github.com/dgynfi/DYFStore )
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
        
        let accountName = "Handsome Jon"
        
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        print("[\(#function)] [line:\(#line)] userIdentifier: \(userIdentifier)")
        
        DYFStore.default.restoreTransactions(userIdentifier: userIdentifier)
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
        print("[\(#function)] [line:\(#line)] productIdentifier: \(productIdentifier)")
        
        let accountName = "Handsome Jon"
        
        let userIdentifier = DYF_SHA256_HashValue(accountName) ?? ""
        print("[\(#function)] [line:\(#line)] userIdentifier: \(userIdentifier)")
        
        DYFStoreManager.shared.buyProduct(productIdentifier, userIdentifier: userIdentifier)
    }
    
}
