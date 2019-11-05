//
//  DYFStoreTransaction.swift
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

public class DYFStoreConverter: NSObject {
    
    /// Instantiates a DYFStoreConverter object.
    public override init() {
        super.init()
    }
    
    /// Encodes a DYFStoreTransaction object.
    ///
    /// - Parameter transaction: A DYFStoreTransaction object.
    /// - Returns: The data object into which the archive is written.
    @objc public static func data(withTransaction transaction: DYFStoreTransaction?) -> Data? {
        
        guard let data = NSMutableData(capacity: 0) else {
            return nil
        }
        
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(transaction)
        archiver.finishEncoding()
        
        return data as Data
    }
    
    /// A DYFStoreTransaction object initialized for decoding data.
    ///
    /// - Parameter data: An archive previously encoded by NSKeyedArchiver.
    /// - Returns: A DYFStoreTransaction object.
    @objc public static func transaction(withData data: Data?) -> DYFStoreTransaction? {
        
        guard let rData = data else {
            return nil
        }
        
        let unarchiver = NSKeyedUnarchiver(forReadingWith: rData)
        let transaction = unarchiver.decodeObject() as? DYFStoreTransaction
        unarchiver.finishDecoding()
        
        return transaction
    }
    
    /// Returns JSON string from a Foundation object. The Options for writing JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter obj: The object from which to generate JSON string. Must not be nil.
    /// - Returns: JSON string for obj, or nil if an internal error occurs.
    @objc public static func json(withObject obj: AnyObject?) -> Data? {
        return json(withObject: obj, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    /// Returns JSON string from a Foundation object.
    ///
    /// - Parameters:
    ///   - obj: The object from which to generate JSON string. Must not be nil.
    ///   - options: Options for writing JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: JSON string for obj, or nil if an internal error occurs.
    @objc public static func json(withObject obj: AnyObject?, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) -> Data? {
        
        guard let anObj = obj else { return nil }
        
        do {
            // let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted /* The pretty output formatting. */
            // let data = try encoder.encode(obj) /* The object complies with the Codable protocol. */
            let data = try JSONSerialization.data(withJSONObject: anObj, options: options)
            
            return data
        } catch let error {
            
            print("JSONSerialization.error: \(error)")
            
            return nil
        }
    }
    
    /// Returns JSON string from a Foundation object. The Options for writing JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter obj: The object from which to generate JSON string. Must not be nil.
    /// - Returns: JSON string for obj, or nil if an internal error occurs.
    @objc public static func jsonString(withObject obj: AnyObject?) -> String? {
        return jsonString(withObject: obj, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    /// Returns JSON string from a Foundation object.
    ///
    /// - Parameters:
    ///   - obj: The object from which to generate JSON string. Must not be nil.
    ///   - options: Options for writing JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: JSON string for obj, or nil if an internal error occurs.
    @objc public static func jsonString(withObject obj: AnyObject?, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) -> String? {
        
        guard let anObj = obj else { return nil }
        
        do {
            // let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted /* The pretty output formatting. */
            // let data = try encoder.encode(obj) /* The object complies with the Codable protocol. */
            let data = try JSONSerialization.data(withJSONObject: anObj, options: options)
            
            return String(data: data, encoding: String.Encoding.utf8)
        } catch let error {
            
            print("JSONSerialization.error: \(error)")
            
            return nil
        }
    }
    
    /// Returns a Foundation object from given JSON data. The options used when creating Foundation objects from JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter data: A data object containing JSON data.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withData data: Data?) -> AnyObject? {
        return jsonObject(withData: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
    }
    
    /// Returns a Foundation object from given JSON data.
    ///
    /// - Parameters:
    ///   - data: A data object containing JSON data.
    ///   - options: Options used when creating Foundation objects from JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withData data: Data?, options: JSONSerialization.ReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)) -> AnyObject? {
        
        guard let aData = data else { return nil }
        
        do {
            // struct GroceryProduct: Codable {
            //     var name: String
            //     var points: Int
            //     var description: String?
            // }
            
            // let json = """
            // {
            //    "name": "Durian",
            //    "points": 600,
            //    "description": "A fruit with a distinctive scent."
            // }
            // """.data(using: .utf8)!
            
            // let decoder = JSONDecoder()
            // let obj = try decoder.decode(GroceryProduct.self, from: json) /* The object complies with the Codable protocol. */
            let obj = try JSONSerialization.jsonObject(with: aData, options: options)
            
            return obj as AnyObject
        } catch let error {
            
            print("JSONSerialization.error: \(error)")
            
            return nil
        }
    }
    
    /// Returns a Foundation object from given JSON string. The options used when creating Foundation objects from JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter json: A string object containing JSON string.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withJSON json: String?) -> AnyObject? {
        return jsonObject(withJSON: json, options: JSONSerialization.ReadingOptions(rawValue: 0))
    }
    
    /// Returns a Foundation object from given JSON string.
    ///
    /// - Parameters:
    ///   - json: A string object containing JSON string.
    ///   - options: Options used when creating Foundation objects from JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withJSON json: String?, options: JSONSerialization.ReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)) -> AnyObject? {
        
        guard let data = json?.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: options)
            
            return obj as AnyObject
        } catch let error {
            
            print("JSONSerialization.error: \(error)")
            
            return nil
        }
    }
    
}
