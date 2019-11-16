//
//  DYFStoreUserDefaultsPersistence.swift
//
//  Created by dyf on 2016/11/28.
//  Copyright © 2016 dyf. ( https://github.com/dgynfi/DYFStoreKit_Swift )
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

import Foundation
import UIKit

open class DYFStoreUserDefaultsPersistence: NSObject {
    
    /// Returns the shared defaults `UserDefaults` object.
    private let userDefaults = UserDefaults.standard
    
    /// Instantiates a DYFStoreUserDefaultsPersistence object.
    public override init() {}
    
    private func loadTransactions() -> [Data]? {
        userDefaults.object(forKey: DYFStoreTransactionsKey)
        return nil
    }
    
    public func storeTransaction(_ transaction: DYFStoreTransaction) {
        
        let data = DYFStoreConverter.encodeObject(transaction)
        guard let aData = data else {
            return
        }
        
        var transactions = loadTransactions() ?? [Data]()
        transactions.append(aData)
        
        userDefaults.set(transactions, forKey: DYFStoreTransactionsKey);
        userDefaults.synchronize()
    }
    
    public func retrieveTransactions() -> [DYFStoreTransaction]?  {
        
        return nil
        
    }
    
    public func retrieveTransaction(_ transactionIdentifier: String) -> DYFStoreTransaction? {
        
        return nil
    }
    
    public func removeTransaction(_ transactionIdentifier: String) {
        
    }
    
    public func removeTransactions() {
        userDefaults.removeObject(forKey: DYFStoreTransactionsKey);
        userDefaults.synchronize()
    }
    
}
