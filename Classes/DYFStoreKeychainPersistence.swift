//
//  DYFStoreKeychainPersistence.swift
//
//  Created by Tenfay on 2016/11/28. ( https://github.com/itenfay/DYFStore )
//  Copyright © 2016 Tenfay. All rights reserved.
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

/// Deprecated file.
import Foundation
#if canImport(DYFSwiftKeychain)
import DYFSwiftKeychain
import DYFSwiftRuntimeProvider

/// The transaction persistence using the keychain.
open class DYFStoreKeychainPersistence: NSObject {
    
    /// Instantiates an `DYFSwiftKeychain` object.
    private lazy var keychain: DYFSwiftKeychain = {
        let keychain = DYFSwiftKeychain()
        return keychain
    }()
    
    /// Loads an array whose elements are the `Dictionary` objects from the keychain.
    ///
    /// - Returns: An array whose elements are the `Dictionary` objects.
    private func loadDataFromKeychain() -> [[String : Any]]? {
        let data = self.keychain.getData(DYFStoreTransactionsKey)
        let array = DYFStoreConverter.jsonObject(withData: data) as? [[String : Any]]
        return array
    }
    
    /// Returns a Boolean value that indicates whether a transaction is present in the keychain with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: True if a transaction is present in the keychain, otherwise false.
    public func containsTransaction(_ transactionIdentifier: String) -> Bool {
        let array = loadDataFromKeychain()
        guard let arr = array, arr.count > 0 else {
            return false
        }
        let tx = arr.compactMap { data in
            return DYFSwiftRuntimeProvider.asObject(with: data, for: DYFStoreTransaction.self)
        }.first { tx in
            let id = tx.transactionIdentifier
            return id == transactionIdentifier
        }
        return tx != nil
    }
    
    /// Stores an `DYFStoreTransaction` object in the keychain item.
    ///
    /// - Parameter transaction: An `DYFStoreTransaction` object.
    public func storeTransaction(_ transaction: DYFStoreTransaction?) {
        let dict = DYFSwiftRuntimeProvider.asDictionary(withObject: transaction)
        guard let aDict = dict else { return }
        
        var transactions = loadDataFromKeychain() ?? [[String : Any]]()
        transactions.append(aDict)
        
        let tData = DYFStoreConverter.json(withObject: transactions)
        self.keychain.set(tData, forKey: DYFStoreTransactionsKey)
    }
    
    /// Retrieves an array whose elements are the `DYFStoreTransaction` objects from the keychain.
    ///
    /// - Returns: An array whose elements are the `DYFStoreTransaction` objects.
    public func retrieveTransactions() -> [DYFStoreTransaction]? {
        let array = loadDataFromKeychain()
        guard let arr = array else { return nil }
        let transactions = arr.compactMap { data in
            return DYFSwiftRuntimeProvider.asObject(with: data, for: DYFStoreTransaction.self)
        }
        return transactions
    }
    
    /// Retrieves an `DYFStoreTransaction` object from the keychain with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    /// - Returns: An `DYFStoreTransaction` object from the keychain.
    public func retrieveTransaction(_ transactionIdentifier: String) -> DYFStoreTransaction? {
        let array = retrieveTransactions()
        guard let arr = array else { return nil }
        let tx = arr.first { tx in
            let id = tx.transactionIdentifier
            let originalId = tx.originalTransactionIdentifier
            return id == transactionIdentifier || originalId == transactionIdentifier
        }
        return tx
    }
    
    /// Removes an `DYFStoreTransaction` object from the keychain with a given transaction ientifier.
    ///
    /// - Parameter transactionIdentifier: The unique server-provided identifier.
    public func removeTransaction(_ transactionIdentifier: String) {
        let array = loadDataFromKeychain()
        guard var arr = array else { return }
        arr.removeAll { data in
            let tx = DYFSwiftRuntimeProvider.asObject(with: data, for: DYFStoreTransaction.self)
            let id = tx?.transactionIdentifier
            let originalId = tx?.originalTransactionIdentifier
            return id == transactionIdentifier || originalId == transactionIdentifier
        }
        let tData = DYFStoreConverter.json(withObject: arr)
        self.keychain.set(tData, forKey: DYFStoreTransactionsKey)
    }
    
    /// Removes all transactions from the keychain.
    public func removeTransactions() {
        self.keychain.delete(DYFStoreTransactionsKey)
    }
    
}

#endif
