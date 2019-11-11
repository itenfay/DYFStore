//
//  DYFSwiftKeychain.swift
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
import Security

/// The class for swift keychain wrapper.
open class DYFSwiftKeychain: NSObject {
    
    /// Specifies an access group which is used to share keychain items between applications.
    @objc public var accessGroup: String?
    
    /// Specifies whether the item is synchronized to other devices through iCloud.
    @objc public var synchronizable: Bool = false
    
    /// The identifierfor for kSecAttrService.
    @objc public var serviceIdentifier: String?
    
    /// Records the query parameters of the last operation.
    @objc public var queryDictionary: [String: Any]?
    
    /// Records the status of the last operation result.
    @objc public var osStatus: OSStatus = errSecSuccess
    
    /// Instantiates a DYFSwiftKeychain object.
    public override init() {
        super.init()
    }
    
    /// Instantiates a DYFSwiftKeychain object.
    ///
    /// - Parameter serviceIdentifier: The identifier for service.
    @objc public convenience init(serviceIdentifier: String?) {
        self.init()
        self.serviceIdentifier = serviceIdentifier
    }
    
    /// The lock prevents the code to be run simultaneously from multiple threads which may result in crashing.
    private var lock: NSLock { return NSLock() }
    
    /// Creates an instance of DYFSwiftKeychain with the class method.
    ///
    /// - Returns: An instance of DYFSwiftKeychain.
    @objc public class func createKeychain() -> DYFSwiftKeychain {
        return DYFSwiftKeychain()
    }
    
    /// Returns a keychain that copies the current DYFSwiftKeychain instance.
    ///
    /// - Returns: A DYFSwiftKeychain object.
    @objc open override func copy() -> Any {
        
        let keychain = DYFSwiftKeychain.self.createKeychain()
        keychain.accessGroup       = self.accessGroup
        keychain.synchronizable    = self.synchronizable
        keychain.serviceIdentifier = self.serviceIdentifier
        keychain.queryDictionary   = self.queryDictionary
        keychain.osStatus          = self.osStatus
        
        return keychain
    }
    
    /// Stores or updates the text value in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The text value to be written to the keychain.
    ///   - key: The key which the text is stored in the keychain.
    /// - Returns: True if the text was successfully written to the keychain, false otherwise.
    @discardableResult
    @objc public func add(_ value: String?, forKey key: String) -> Bool {
        
        let opts = DYFSwiftKeychainAccessOptions.accessibleWhenUnlocked
        
        return add(value, forKey: key, options: opts)
    }
    
    @discardableResult
    /// Stores or updates the text value in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The text value to be written to the keychain.
    ///   - key: The key which the text is stored in the keychain.
    ///   - options: The options indicates when you app needs access to the text in the keychain. By the default DYFSwiftKeychainAccessOptions.accessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
    /// - Returns: True if the text was successfully written to the keychain, false otherwise.
    @objc public func add(_ value: String?, forKey key: String, options: DYFSwiftKeychainAccessOptions) -> Bool {
        
        let v = value?.data(using: String.Encoding.utf8)
        let opts = toOpts(options)
        
        return set(v, forKey: key, withAccess: opts)
    }
    
    @discardableResult
    /// Stores or updates the text value in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The text value to be written to the keychain.
    ///   - key: The key which the text is stored in the keychain.
    ///   - access: The parameter indicates when you app needs access to the text in the keychain. By the default DYFSwiftKeychain.AccessOptions.accessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
    /// - Returns: True if the text was successfully written to the keychain, false otherwise.
    public func set(_ value: String?, forKey key: String, withAccess access: DYFSwiftKeychain.AccessOptions? = nil) -> Bool {
        
        let v = value?.data(using: String.Encoding.utf8)
        
        return set(v, forKey: key, withAccess: access)
    }
    
    /// Stores or updates the data in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The data to be written to the keychain.
    ///   - key: The key which the data is stored in the keychain.
    /// - Returns: True if the data was successfully written to the keychain, false otherwise.
    @discardableResult
    @objc public func addData(_ value: Data?, forKey key: String) -> Bool {
        
        let opts = DYFSwiftKeychainAccessOptions.accessibleWhenUnlocked
        
        return addData(value, forKey: key, options: opts)
    }
    
    /// Stores or updates the data in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The data to be written to the keychain.
    ///   - key: The key which the data is stored in the keychain.
    ///   - options: The options indicates when you app needs access to the text in the keychain. By the default DYFSwiftKeychainAccessOptions.accessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
    /// - Returns: True if the data was successfully written to the keychain, false otherwise.
    @discardableResult
    @objc public func addData(_ value: Data?, forKey key: String, options: DYFSwiftKeychainAccessOptions) -> Bool {
        
        let opts = toOpts(options)
        
        return set(value, forKey: key, withAccess: opts)
    }
    
    /// Stores or updates the data in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: Stores or updates the data in the keychain item by the given key.
    ///   - key: The key which the data is stored in the keychain.
    ///   - access: The parameter indicates when you app needs access to the text in the keychain. By the default DYFSwiftKeychain.AccessOptions.accessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
    /// - Returns: True if the data was successfully written to the keychain, false otherwise.
    @discardableResult
    public func set(_ value: Data?, forKey key: String, withAccess access: DYFSwiftKeychain.AccessOptions? = nil) -> Bool {
        
        // The lock prevents the code to be run simultaneously from multiple threads which may result in crashing.
        lock.lock()
        defer { lock.unlock() }
        
        let accessible = access?.value ?? DYFSwiftKeychain.AccessOptions.defaultOption.value
        
        var query: [String: Any] = supplyQueryDictionary()
        query[DYFSwiftKeychain.Constants.account] = key
        query[DYFSwiftKeychain.Constants.accessible] = accessible
        queryDictionary = query
        
        guard let data = getData(key) else {
            
            if let v = value {
                query[DYFSwiftKeychain.Constants.valueData] = v
                queryDictionary?[DYFSwiftKeychain.Constants.valueData] = v
                
                osStatus = SecItemAdd(query as CFDictionary, nil)
            } else {
                osStatus = errSecInvalidPointer // -67675, An invalid pointer was encountered.
            }
            
            return osStatus == errSecSuccess
        }
        
        let _ = data // ignores this data.
        if let v = value {
            let updatedDictionary: [String: Any] = [
                DYFSwiftKeychain.Constants.valueData: v
            ]
            
            osStatus = SecItemUpdate(query as CFDictionary, updatedDictionary as CFDictionary)
        } else {
            deleteWithoutLock(key)
            osStatus = errSecInvalidPointer // -67675, An invalid pointer was encountered.
        }
        
        return osStatus == errSecSuccess
    }
    
    /// Stores or updates the boolean value in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The boolean value to be written to the keychain.
    ///   - key: The key which the boolean value is stored in the keychain.
    /// - Returns: True if the boolean value was successfully written to the keychain, false otherwise.
    @discardableResult
    @objc public func addBool(_ value: Bool, forKey key: String) -> Bool {
        
        let opts = DYFSwiftKeychainAccessOptions.accessibleWhenUnlocked
        
        return addBool(value, forKey: key, options: opts)
    }
    
    /// Stores or updates the boolean value in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The boolean value to be written to the keychain.
    ///   - key: The key which the boolean value is stored in the keychain.
    ///   - options: The options indicates when you app needs access to the text in the keychain. By the default DYFSwiftKeychainAccessOptions.accessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
    /// - Returns: True if the boolean value was successfully written to the keychain, false otherwise.
    @discardableResult
    @objc public func addBool(_ value: Bool, forKey key: String, options: DYFSwiftKeychainAccessOptions) -> Bool {
        
        let opts = toOpts(options)
        
        return set(value, forKey: key, withAccess: opts)
    }
    
    /// Stores or updates the boolean value in the keychain item by the given key.
    ///
    /// - Parameters:
    ///   - value: The boolean value to be written to the keychain.
    ///   - key: The key which the boolean value is stored in the keychain.
    ///   - access: The parameter indicates when you app needs access to the text in the keychain. By the default DYFSwiftKeychain.AccessOptions.accessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
    /// - Returns: True if the boolean value was successfully written to the keychain, false otherwise.
    @discardableResult
    public func set(_ value: Bool, forKey key: String, withAccess access: DYFSwiftKeychain.AccessOptions? = nil) -> Bool {
        
        let bytes: [UInt8] = value ? [1] : [0]
        let data = Data(bytes: bytes, count: bytes.count)
        
        return set(data, forKey: key, withAccess: access)
    }
    
    /// Retrieves the text value from the keychain by the given key.
    ///
    /// - Parameter key: The key that is used to read the keychain item.
    /// - Returns: The text value from the keychain. Nil if unable to read the item.
    @discardableResult
    @objc public func get(_ key: String) -> String? {
        
        if let data = getData(key) {
            
            if let s = String(data: data, encoding: String.Encoding.utf8) {
                return s
            }
            
            osStatus = errSecInvalidEncoding // -67853, the encoding was not valid.
        }
        
        return nil
    }
    
    /// Retrieves the data from the keychain by the given key.
    ///
    /// - Parameter key: The key that is used to read the keychain item.
    /// - Returns: The data from the keychain. Nil if unable to read the item.
    @discardableResult
    @objc public func getData(_ key: String) -> Data? {
        return getData(key, asReference: false)
    }
    
    /// Retrieves the data from the keychain by the given key.
    ///
    /// - Parameters:
    ///   - key: The key that is used to read the keychain item.
    ///   - asReference: If true, returns the data as reference (needed for things like NEVPNProtocol).
    /// - Returns: The data from the keychain. Nil if unable to read the item.
    @discardableResult
    @objc public func getData(_ key: String, asReference: Bool = false) -> Data? {
        
        lock.lock()
        defer { lock.unlock() }
        
        var query: [String: Any] = supplyQueryDictionary()
        query[DYFSwiftKeychain.Constants.account] = key
        query[DYFSwiftKeychain.Constants.matchLimit] = kSecMatchLimitOne
        
        if asReference {
            query[DYFSwiftKeychain.Constants.returnReference] = kCFBooleanTrue
        } else {
            query[DYFSwiftKeychain.Constants.returnData] = kCFBooleanTrue
        }
        queryDictionary = query
        
        var result: AnyObject?
        
        osStatus = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if osStatus == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    /// Retrieves the boolean value from the keychain by the given key.
    ///
    /// - Parameter key: The key that is used to read the keychain item.
    /// - Returns: The boolean value from the keychain. False if unable to read the item.
    @discardableResult
    @objc public func getBool(_ key: String) -> Bool {
        guard let bool = getBool(key) else {
            return false
        }
        
        return bool
    }
    
    /// Retrieves the boolean value from the keychain by the given key.
    ///
    /// - Parameter key: The key that is used to read the keychain item.
    /// - Returns: The boolean value from the keychain. Nil if unable to read the item.
    @discardableResult
    public func getBool(_ key: String) -> Bool? {
        guard let data  = getData(key) else { return nil }
        guard let first = data.first   else { return nil }
        
        return first == 1
    }
    
    /// Deletes the single keychain item by the specified key.
    ///
    /// - Parameter key: The key which is used to delete the keychain item.
    /// - Returns: True if the item was successfully deleted, false otherwise.
    @discardableResult
    @objc public func delete(_ key: String) -> Bool {
        
        lock.lock()
        defer { lock.unlock() }
        
        let ret = deleteWithoutLock(key)
        
        return ret
    }
    
    /// Same as `delete`, but it is not thread safe.
    ///
    /// - Parameter key: The key which is used to delete the keychain item.
    /// - Returns: True if the item was successfully deleted, false otherwise.
    @discardableResult
    private func deleteWithoutLock(_ key: String) -> Bool {
        
        var query: [String: Any] = supplyQueryDictionary()
        query[DYFSwiftKeychain.Constants.account] = key
        queryDictionary = query
        
        osStatus = SecItemDelete(query as CFDictionary)
        
        return osStatus == errSecSuccess
    }
    
    /// Deletes all keychain items used by the app. Note that this method deletes all items regardless of those used keys.
    ///
    /// - Returns: True if all keychain items was successfully deleted, false otherwise.
    @discardableResult
    @objc public func clear() -> Bool {
        
        lock.lock()
        defer { lock.unlock() }
        
        let query: [String: Any] = supplyQueryDictionary()
        queryDictionary = query
        
        osStatus = SecItemDelete(query as CFDictionary)
        
        return osStatus == errSecSuccess // 0, no error.
    }
    
    /// Supplies a query dictionary to modify the keychain item.
    ///
    /// - Parameter shouldAddItem: Use `true` when the dictionary will be used with `SecItemAdd` or `SecItemUpadte` method. For getting and deleting items, use `false`
    /// - Returns: A query dictionary to modify the keychain item.
    private func supplyQueryDictionary(shouldAddItem: Bool = false) -> [String: Any] {
        
        var query: [String: Any] = [
            DYFSwiftKeychain.Constants.kClass: kSecClassGenericPassword
        ]
        
        if let accessGroup = accessGroup {
            query[DYFSwiftKeychain.Constants.accessGroup] = accessGroup
        }
        
        if synchronizable {
            let key = DYFSwiftKeychain.Constants.synchronizable
            query[key] = shouldAddItem ? kCFBooleanTrue : kSecAttrSynchronizableAny
        }
        
        if let serviceId = serviceIdentifier {
            query[DYFSwiftKeychain.Constants.service] = serviceId
        }
        
        return query
    }
    
}

extension DYFSwiftKeychain {
    
    /// These options are used to determine when a keychain item should be readable.
    public enum AccessOptions {
        
        /// Converts a corresponding enumeration value to a string.
        var value: String {
            switch self {
            case .accessibleWhenUnlocked:
                return kSecAttrAccessibleWhenUnlocked as String
                
            case .accessibleWhenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
                
            case .accessibleAfterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock as String
                
            case .accessibleAfterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
                
            case .acessibleWhenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
                
            case .accessibleAlways:
                return kSecAttrAccessibleAlways as String
                
            case .accessibleAlwaysThisDeviceOnly:
                return kSecAttrAccessibleAlwaysThisDeviceOnly as String
            }
        }
        
        /// The default value is accessibleWhenUnlocked
        static var defaultOption: AccessOptions {
            return .accessibleWhenUnlocked
        }
        
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        ///
        /// This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
        /// This is the default value for keychain items added without explicitly setting an accessibility constant.
        case accessibleWhenUnlocked
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        ///
        /// This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
        case accessibleWhenUnlockedThisDeviceOnly
        
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        ///
        /// After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
        case accessibleAfterFirstUnlock
        ///  The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        ///
        /// After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
        case accessibleAfterFirstUnlockThisDeviceOnly
        
        /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
        ///
        /// This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
        case acessibleWhenPasscodeSetThisDeviceOnly
        
        /// The data in the keychain item can always be accessed regardless of whether the device is locked.
        ///
        /// This is not recommended for application use. Items with this attribute migrate to a new device when using encrypted backups.
        case accessibleAlways
        /// The data in the keychain item can always be accessed regardless of whether the device is locked.
        ///
        /// This is not recommended for application use. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
        case accessibleAlwaysThisDeviceOnly
    }
    
    /// Constants used by the library
    public struct Constants {
        
        /// Specifies an access group which is used to share keychain items between apps.
        public static var accessGroup: String {
            return toString(kSecAttrAccessGroup)
        }
        
        /// The value indicates when your app needs access to the data in a keychain item.
        public static var accessible: String {
            return toString(kSecAttrAccessible)
        }
        
        /// The value indicates whether the item is synchronized to other devices through iCloud.
        ///
        /// Indicates whether the item in question is synchronized to other devices through iCloud. To add a new synchronizable item, or to obtain synchronizable results from a query, supply this key with a value of kCFBooleanTrue. If the key is not supplied, or has a value of kCFBooleanFalse, then no synchronizable items are added or returned. Use kSecAttrSynchronizableAny to query for both synchronizable and non-synchronizable results.
        public static var synchronizable: String {
            return toString(kSecAttrSynchronizable)
        }
        
        /// A value is a string indicating the item's account name.
        public static var account: String {
            return toString(kSecAttrAccount)
        }
        
        /// A key whose value is a string indicating the item's service.
        ///
        /// Represents the service associated with this item. Items of class kSecClassGenericPassword have this attribute.
        public static var service: String {
            return toString(kSecAttrService)
        }
        
        /// A value is the item's class.
        public static var kClass: String {
            return toString(kSecClass)
        }
        
        /// A value indicates the match limit.
        public static var matchLimit: String {
            return toString(kSecMatchLimit)
        }
        
        /// A value is the item's data.
        public static var valueData: String {
            return toString(kSecValueData)
        }
        
        /// A value is a Boolean indicating whether or not to return item data.
        public static var returnData: String {
            return toString(kSecReturnData)
        }
        
        /// A value is a Boolean indicating whether or not to return a persistent reference to an item.
        public static var returnReference: String {
            return toString(kSecReturnPersistentRef)
        }
        
        /// Converts a CFString object to a string.
        ///
        /// - Parameter value: A reference to a CFString object.
        /// - Returns: A string.
        static func toString(_ value: CFString) -> String {
            return value as String
        }
        
    }
    
    /// Converts a DYFSwiftKeychainAccessOptions value to a DYFSwiftKeychain.AccessOptions value.
    ///
    /// - Parameter opts: A DYFSwiftKeychainAccessOptions value.
    /// - Returns: A DYFSwiftKeychain.AccessOptions value.
    private func toOpts(_ opts: DYFSwiftKeychainAccessOptions) -> DYFSwiftKeychain.AccessOptions? {
        
        var options: DYFSwiftKeychain.AccessOptions? = nil
        
        switch opts {
        case .accessibleWhenUnlocked:
            options = DYFSwiftKeychain.AccessOptions.accessibleWhenUnlocked
            break
        case .accessibleWhenUnlockedThisDeviceOnly:
            options = DYFSwiftKeychain.AccessOptions.accessibleWhenUnlockedThisDeviceOnly
            break
        case .accessibleAfterFirstUnlock:
            options = DYFSwiftKeychain.AccessOptions.accessibleAfterFirstUnlock
            break
        case .accessibleAfterFirstUnlockThisDeviceOnly:
            options = DYFSwiftKeychain.AccessOptions.accessibleAfterFirstUnlockThisDeviceOnly
            break
        case .acessibleWhenPasscodeSetThisDeviceOnly:
            options = DYFSwiftKeychain.AccessOptions.acessibleWhenPasscodeSetThisDeviceOnly
            break
        case .accessibleAlways:
            options = DYFSwiftKeychain.AccessOptions.accessibleAlways
            break
        case .accessibleAlwaysThisDeviceOnly:
            options = DYFSwiftKeychain.AccessOptions.accessibleAlwaysThisDeviceOnly
            break
        default: break
        }
        
        return options
    }
    
}

/// Used to represent accessible access options.
@objc public enum DYFSwiftKeychainAccessOptions: UInt8 {
    
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    ///
    /// This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
    /// This is the default value for keychain items added without explicitly setting an accessibility constant.
    case accessibleWhenUnlocked
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    ///
    /// This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
    case accessibleWhenUnlockedThisDeviceOnly
    
    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    ///
    /// After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
    case accessibleAfterFirstUnlock
    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    ///
    /// After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
    case accessibleAfterFirstUnlockThisDeviceOnly
    
    /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
    ///
    /// This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
    case acessibleWhenPasscodeSetThisDeviceOnly
    
    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    ///
    /// This is not recommended for application use. Items with this attribute migrate to a new device when using encrypted backups.
    case accessibleAlways
    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    ///
    /// This is not recommended for application use. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
    case accessibleAlwaysThisDeviceOnly
}
