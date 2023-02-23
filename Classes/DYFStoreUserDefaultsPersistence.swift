//
//  DYFStoreUserDefaultsPersistence.swift
//
//  Created by chenxing on 2016/11/28. ( https://github.com/chenxing640/DYFStore )
//  Copyright © 2016 chenxing. All rights reserved.
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

/// Returns the shared defaults `UserDefaults` object.
fileprivate let kUserDefaults = UserDefaults.standard

/// The transaction persistence using the UserDefaults.
open class DYFStoreUserDefaultsPersistence: NSObject {
    
    /// Loads an array whose elements are the `Data` objects from the shared preferences search list.
    ///
    /// - Returns: An array whose elements are the `Data` objects.
    private func loadDataFromUserDefaults() -> [Data]? {
        let obj = kUserDefaults.object(forKey: DYFStoreTransactionsKey)
        return obj as? [Data]
    }
    
    /// Returns a Boolean value that indicates whether a transaction is present in shared preferences search list with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: True if a transaction is present in shared preferences search list, otherwise false.
    public func containsTransaction(_ transactionIdentifier: String) -> Bool {
        let array = loadDataFromUserDefaults()
        guard let arr = array, arr.count > 0 else {
            return false
        }
        for data in arr {
            let obj = DYFStoreConverter.decodeObject(data)
            let transaction = obj as? DYFStoreTransaction
            let identifier = transaction?.transactionIdentifier
            if let id = identifier, id == transactionIdentifier {
                return true
            }
        }
        return false
    }
    
    /// Stores an `DYFStoreTransaction` object in the shared preferences search list.
    ///
    /// - Parameter transaction: An `DYFStoreTransaction` object.
    public func storeTransaction(_ transaction: DYFStoreTransaction?) {
        let data = DYFStoreConverter.encodeObject(transaction)
        guard let aData = data else {
            return
        }
        var transactions = loadDataFromUserDefaults() ?? [Data]()
        transactions.append(aData)
        
        kUserDefaults.set(transactions, forKey: DYFStoreTransactionsKey)
        kUserDefaults.synchronize()
    }
    
    /// Retrieves an array whose elements are the `DYFStoreTransaction` objects from the shared preferences search list.
    ///
    /// - Returns: An array whose elements are the `DYFStoreTransaction` objects.
    public func retrieveTransactions() -> [DYFStoreTransaction]? {
        let array = loadDataFromUserDefaults()
        guard let arr = array else {
            return nil
        }
        var transactions = [DYFStoreTransaction]()
        for item in arr {
            let obj = DYFStoreConverter.decodeObject(item)
            if let transaction = obj as? DYFStoreTransaction {
                transactions.append(transaction)
            }
        }
        return transactions
    }
    
    /// Retrieves an `DYFStoreTransaction` object from the shared preferences search list with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: An `DYFStoreTransaction` object from the shared preferences search list.
    public func retrieveTransaction(_ transactionIdentifier: String) -> DYFStoreTransaction? {
        let array = retrieveTransactions()
        guard let arr = array else {
            return nil
        }
        for transaction in arr {
            let identifier = transaction.transactionIdentifier
            if identifier == transactionIdentifier {
                return transaction
            }
        }
        return nil
    }
    
    /// Removes an `DYFStoreTransaction` object from the shared preferences search list with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    public func removeTransaction(_ transactionIdentifier: String) {
        let array = loadDataFromUserDefaults()
        guard var arr = array else {
            return
        }
        var index = -1
        for (idx, data) in arr.enumerated() {
            let obj = DYFStoreConverter.decodeObject(data)
            let transaction = obj as? DYFStoreTransaction
            let identifier = transaction?.transactionIdentifier
            if let id = identifier, id == transactionIdentifier {
                index = idx
                break
            }
        }
        guard index >= 0 else { return }
        arr.remove(at: index)
        
        kUserDefaults.setValue(arr, forKey: DYFStoreTransactionsKey)
        kUserDefaults.synchronize()
    }
    
    /// Removes all transactions from the shared preferences search list.
    public func removeTransactions() {
        kUserDefaults.removeObject(forKey: DYFStoreTransactionsKey);
        kUserDefaults.synchronize()
    }
    
}
