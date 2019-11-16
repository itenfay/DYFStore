//
//  DYFStoreKeychainPersistence.swift
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

/// The transaction persistence using the keychain.
open class DYFStoreKeychainPersistence: NSObject {
    
    /// Instantiates a DYFStoreKeychainPersistence object.
    public override init() {}
    
    /// Loads an array whose elements are the `Data` objects from the keychain.
    ///
    /// - Returns: An array whose elements are the `Data` objects.
    private func loadTransactions() -> [Data]? {
        
        let keychain = DYFSwiftKeychain()
        let data = keychain.getData(DYFStoreTransactionsKey)
        
        let array = DYFStoreConverter.jsonObject(withData: data) as? [Data]
        guard let arr = array else {
            return nil
        }
        
        return arr
    }
    
    /// Stores an `DYFStoreTransaction` object in the keychain item.
    ///
    /// - Parameter transaction: An `DYFStoreTransaction` object.
    public func storeTransaction(_ transaction: DYFStoreTransaction) {
        
        let data = DYFStoreConverter.encodeObject(transaction)
        guard let aData = data else {
            return
        }
        
        var transactions = loadTransactions() ?? [Data]()
        transactions.append(aData)
        
        let tData = DYFStoreConverter.json(withObject: transactions)
        let keychain = DYFSwiftKeychain()
        keychain.set(tData, forKey: DYFStoreTransactionsKey)
    }
    
    /// Retrieves an array whose elements are the `DYFStoreTransaction` objects from the keychain.
    ///
    /// - Returns: An array whose elements are the `DYFStoreTransaction` objects.
    public func retrieveTransactions() -> [DYFStoreTransaction]? {
        
        let array = loadTransactions()
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
    
    /// Retrieves an `DYFStoreTransaction` object from the keychain with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: An `DYFStoreTransaction` object from the keychain.
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
    
    /// Removes an `DYFStoreTransaction` object from the keychain with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    public func removeTransaction(_ transactionIdentifier: String) {
        
        let array = loadTransactions()
        guard var arr = array else {
            return
        }
        
        var index: Int = -1
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
        
        let keychain = DYFSwiftKeychain()
        arr.remove(at: index)
        
        let tData = DYFStoreConverter.json(withObject: arr)
        keychain.set(tData, forKey: DYFStoreTransactionsKey)
    }
    
    /// Removes all transactions from the keychain.
    public func removeTransactions() {
        let keychain = DYFSwiftKeychain()
        keychain.delete(DYFStoreTransactionsKey)
    }
    
}
