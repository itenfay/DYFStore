//
//  DYFStoreTransaction.swift
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

/// The converter is used to convert json and json object to each other,
/// convert an object and a data object to each other.
public class DYFStoreConverter: NSObject {
    
    /// Instantiates an `DYFStoreConverter` object.
    public override init() {
        super.init()
    }
    
    /// Encodes an object.
    ///
    /// - Parameter object: An object you want to encode.
    /// - Returns: The data object into which the archive is written.
    @objc public static func encodeObject(_ object: Any?) -> Data? {
        guard let obj = object else {
            return nil
        }
        
        if #available(iOS 11.0, *) {
            let archiver = NSKeyedArchiver(requiringSecureCoding: false)
            archiver.encode(obj)
            return archiver.encodedData // archiver.finishEncoding() and return the data.
        }
        
        return NSKeyedArchiver.archivedData(withRootObject: obj);
    }
    
    /// Returns an object initialized for decoding data.
    ///
    /// - Parameter data: An archive previously encoded by NSKeyedArchiver.
    /// - Returns: An object initialized for decoding data.
    @objc public static func decodeObject(_ data: Data?) -> Any? {
        guard let tData = data else {
            return nil
        }
        
        if #available(iOS 11.0, *) {
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: tData)
                unarchiver.requiresSecureCoding = false
                let object = unarchiver.decodeObject()
                unarchiver.finishDecoding()
                return object
            } catch let error {
                #if DEBUG
                print("\((#file as NSString).lastPathComponent):\(#function):\(#line) error: \(error.localizedDescription)")
                #endif
                return nil
            }
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: tData)
    }
    
    /// Returns JSON data from a Foundation object. The Options for writing JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter obj: The object from which to generate JSON data.
    /// - Returns: JSON data for obj, or nil if an internal error occurs.
    @objc public static func json(withObject obj: Any?) -> Data? {
        return json(withObject: obj, options: [])
    }
    
    /// Returns JSON data from a Foundation object.
    ///
    /// - Parameters:
    ///   - obj: The object from which to generate JSON data.
    ///   - options: Options for writing JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: JSON data for obj, or nil if an internal error occurs.
    @objc public static func json(withObject obj: Any?, options: JSONSerialization.WritingOptions = []) -> Data? {
        guard let anObj = obj else { return nil }
        do {
            // let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted /* The pretty output formatting. */
            // let data = try encoder.encode(obj) /* The object complies with the Codable protocol. */
            let data = try JSONSerialization.data(withJSONObject: anObj, options: options)
            return data
        } catch let error {
            #if DEBUG
            print("\((#file as NSString).lastPathComponent):\(#function):\(#line) error: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
    
    /// Returns JSON string from a Foundation object. The Options for writing JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter obj: The object from which to generate JSON string.
    /// - Returns: JSON string for obj, or nil if an internal error occurs.
    @objc public static func jsonString(withObject obj: Any?) -> String? {
        return jsonString(withObject: obj, options: [])
    }
    
    /// Returns JSON string from a Foundation object.
    ///
    /// - Parameters:
    ///   - obj: The object from which to generate JSON string.
    ///   - options: Options for writing JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: JSON string for obj, or nil if an internal error occurs.
    @objc public static func jsonString(withObject obj: Any?, options: JSONSerialization.WritingOptions = []) -> String? {
        guard let anObj = obj else { return nil }
        do {
            // let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted /* The pretty output formatting. */
            // let data = try encoder.encode(obj) /* The object complies with the Codable protocol. */
            let data = try JSONSerialization.data(withJSONObject: anObj, options: options)
            return String(data: data, encoding: String.Encoding.utf8)
        } catch let error {
            #if DEBUG
            print("\((#file as NSString).lastPathComponent):\(#function):\(#line) error: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
    
    /// Returns a Foundation object from given JSON data. The options used when creating Foundation objects from JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter data: A data object containing JSON data.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withData data: Data?) -> Any? {
        return jsonObject(withData: data, options: [])
    }
    
    /// Returns a Foundation object from given JSON data.
    ///
    /// - Parameters:
    ///   - data: A data object containing JSON data.
    ///   - options: Options used when creating Foundation objects from JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withData data: Data?, options: JSONSerialization.ReadingOptions = []) -> Any? {
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
            return obj
        } catch let error {
            #if DEBUG
            print("\((#file as NSString).lastPathComponent):\(#function):\(#line) error: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
    
    /// Returns a Foundation object from given JSON string. The options used when creating Foundation objects from JSON data is equivalent to kNilOptions in Objective-C.
    ///
    /// - Parameter json: A string object containing JSON string.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withJSON json: String?) -> Any? {
        return jsonObject(withJSON: json, options: [])
    }
    
    /// Returns a Foundation object from given JSON string.
    ///
    /// - Parameters:
    ///   - json: A string object containing JSON string.
    ///   - options: Options used when creating Foundation objects from JSON data. The default value is equivalent to kNilOptions in Objective-C.
    /// - Returns: A Foundation object from the JSON data in data, or nil if an error occurs.
    @objc public static func jsonObject(withJSON json: String?, options: JSONSerialization.ReadingOptions = []) -> Any? {
        guard let data = json?.data(using: String.Encoding.utf8) else {
            return nil
        }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: options)
            return obj
        } catch let error {
            #if DEBUG
            print("\((#file as NSString).lastPathComponent):\(#function):\(#line) error: \(error)")
            #endif
            return nil
        }
    }
    
}
