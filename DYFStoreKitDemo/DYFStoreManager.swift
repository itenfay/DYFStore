//
//  DYFStoreManager.swift
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
import CommonCrypto

/// Custom method to calculate the SHA-256 hash using Common Crypto.
///
/// - Parameter s: A string to calculate hash.
/// - Returns: A SHA-256 hash value.
public func DYF_SHA256_HashValue(_ s: String) -> String? {
    
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH) // 32
    
    let cStr = s.cString(using: String.Encoding.utf8)!
    let cStrLen = Int(s.lengthOfBytes(using: String.Encoding.utf8))
    
    // Confirm that the length of C string is small enough
    // to be recast when calling the hash function.
    if cStrLen > UINT32_MAX {
        print("C string too long to hash: \(s)")
        return nil
    }
    
    let md = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
    
    CC_SHA256(cStr, CC_LONG(cStrLen), md)
    
    // Convert the array of bytes into a string showing its hex represention.
    let hash = NSMutableString()
    for i in 0..<digestLength {
        
        // Add a dash every four bytes, for readability.
        if i != 0 && i%4 == 0 {
            //hash.append("-")
        }
        hash.appendFormat("%02x", md[i])
    }
    
    md.deallocate()
    
    return hash as String
}

open class DYFStoreManager: NSObject, DYFStoreReceiptVerifierDelegate {
    
    /// The property contains the purchase information.
    private var purchaseInfo: DYFStore.NotificationInfo?
    /// The property contains the download information.
    private var downloadInfo: DYFStore.NotificationInfo?
    
    /// Creates and returns a receipt verifier by using lazy loading.
    private lazy var receiptVerifier: DYFStoreReceiptVerifier = {
        let verifier = DYFStoreReceiptVerifier()
        verifier.delegate = self
        return verifier
    }()
    
    /// A struct named "Static".
    private struct Static {
        static var instance: DYFStoreManager? = nil
    }
    
    /// Returns a store manager singleton.
    public class var shared: DYFStoreManager {
        
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard let instance = Static.instance else {
            Static.instance = DYFStoreManager()
            return Static.instance!
        }
        
        return instance
    }
    
    /// Overrides default constructor.
    public override init() {
        super.init()
        self.addStoreObserver()
    }
    
    /// deinit
    deinit {
        DYFStoreLog("deinit")
        self.removeStoreObserver()
    }
    
    /// Make sure the class has only one instance.
    open override func copy() -> Any {
        return self
    }
    
    /// Make sure the class has only one instance.
    open override func mutableCopy() -> Any {
        return self
    }
    
    private func addStoreObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processPurchaseNotification(_:)), name: DYFStore.purchasedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DYFStoreManager.processDownloadNotification(_:)), name: DYFStore.downloadedNotification, object: nil)
    }
    
    private func removeStoreObserver() {
        NotificationCenter.default.removeObserver(self, name: DYFStore.purchasedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: DYFStore.downloadedNotification, object: nil)
    }
    
    @objc private func processPurchaseNotification(_ notification: Notification) {
        
    }
    
    @objc private func processDownloadNotification(_ notification: Notification) {
        
    }
    
    private func completePayment() {
        
        let info = self.purchaseInfo
        let store = DYFStore.default
        let persister = store.keychainPersister!
        
        let identifier = info!.transactionIdentifier!
        if !persister.containsTransaction(identifier) {
            self.storeReceipt()
            return
        }
        
        
    }
    
    private func storeReceipt() {
        
    }
    
    private func refreshReceipt() {
        
    }
    
    private func failToRefreshReceipt() {
        
    }
    
    private func verifyReceipt(_ receiptData: Data) {
        
    }
    
    private func retryToVerifyReceipt() {
        
    }
    
    private func sendNotice(_ message: String) {
        
        self.showAlert(withTitle: NSLocalizedString("Notification", tableName: nil, comment: ""),
                       message: message,
                       cancelButtonTitle: nil,
                       cancel: nil,
                       confirmButtonTitle: NSLocalizedString("I see!", tableName: nil, comment: "")) { (action) in
                        DYFStoreLog("Alert action title: %@", action.title!)
        }
    }
    
    // MARK: - DYFStoreReceiptVerifierDelegate
    
    public func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any]) {
        
    }
    
    public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {
        
    }
    
}
