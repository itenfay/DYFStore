//
//  DYFSwiftRuntimeProvider.swift
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

/// The class for runtime wrapper that provides some common practical applications.
public class DYFSwiftRuntimeProvider: NSObject {
    
    /// Instantiates a DYFSwiftRuntimeProvider object.
    public override init() {
        super.init()
    }
    
    /// Describes the instance methods implemented by a class.
    ///
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the instance methods.
    @objc public class func methodList(withClass cls: AnyClass?) -> [String] {
        var names: [String] = [String]()
        
        var count: UInt32 = 0
        let methodList: UnsafeMutablePointer<Method>? = class_copyMethodList(cls, &count)
        
        for index in 0..<Int(count) {
            let sel = method_getName(methodList![index])
            let selName = String(cString: sel_getName(sel))
            names.append(selName)
        }
        
        return names
    }
    
    /// To get the class methods of a class.
    ///
    /// - Parameter obj: The object you want to inspect.
    /// - Returns: String array of the class methods.
    @objc public class func classMethodList(_ obj: Any?) -> [String] {
        var names: [String] = [String]()
        
        var count: UInt32 = 0
        let methodList = class_copyMethodList(object_getClass(obj), &count)
        
        for index in 0..<Int(count) {
            let sel = method_getName(methodList![index])
            let selName = String(cString: sel_getName(sel))
            names.append(selName)
        }
        
        return names
    }
    
    /// Describes the instance variables declared by a class.
    ///
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the instance variables.
    @objc public class func ivarList(withClass cls: AnyClass?) -> [String] {
        var names: [String] = [String]()
        
        var count: UInt32 = 0
        let ivarList = class_copyIvarList(cls, &count)
        
        for index in 0..<Int(count) {
            let ivar = ivarList![index]
            
            if let ivarName = ivar_getName(ivar) {
                let s = String(cString: ivarName)
                names.append(s)
            }
        }
        
        return names
    }
    
    /// Adds a new method to a class with a given selector and implementation.
    ///
    /// - Parameters:
    ///   - cls: The class to which to add a method.
    ///   - sel: A selector that specifies the name of the method being added.
    ///   - impCls: The class you want to inspect.
    ///   - impSel: The selector of the method you want to retrieve.
    /// - Returns: A Bool value.
    @objc public class func addMethod(withClass cls: AnyClass?, selector sel: Selector, impClass impCls: AnyClass? = nil, impSelector impSel: Selector) -> Bool {
        
        let _impCls: AnyClass? = impCls ?? cls
        
        guard let imp = class_getMethodImplementation(_impCls, impSel) else {
            return false
        }
        
        var types: UnsafePointer<Int8>? = nil
        let method = class_getInstanceMethod(_impCls, impSel)
        if let m = method {
            types = method_getTypeEncoding(m)
        }
        
        return class_addMethod(cls, sel, imp, types)
    }
    
    /// Adds a new method to a class with a given selector and implementation.
    ///
    /// - Parameters:
    ///   - cls: The class to which to add a method.
    ///   - sel: A selector that specifies the name of the method being added.
    ///   - impCls: The class you want to inspect.
    ///   - impSel: The selector of the method you want to retrieve.
    ///   - types: A string describing a method's parameter and return types. e.g.: "v@:"
    /// - Returns: A Bool value.
    @objc public class func addMethod(withClass cls: AnyClass?, selector sel: Selector, impClass impCls: AnyClass? = nil, impSelector impSel: Selector, types: String) -> Bool {
        
        let _impCls: AnyClass? = impCls ?? cls
        
        guard let imp = class_getMethodImplementation(_impCls, impSel) else {
            return false
        }
        
        let _types: UnsafePointer<Int8>? = (types as NSString).utf8String
        
        return class_addMethod(cls, sel, imp, _types)
    }
    
    /// Exchanges the implementations of two methods.
    ///
    /// - Parameters:
    ///   - cls: The class you want to modify.
    ///   - sel: A selector that identifies the method whose implementation you want to exchange.
    ///   - targetCls: The class you want to specify.
    ///   - targetSel: The selector of the method you want to retrieve.
    @objc public class func exchangeMethod(withClass cls: AnyClass?, selector sel: Selector, targetClass targetCls: AnyClass?, targetSelector targetSel: Selector) {
        
        guard let m1 = class_getInstanceMethod(cls, sel), let m2 = class_getInstanceMethod(targetCls, targetSel) else {
            return
        }
        
        method_exchangeImplementations(m1, m2)
    }
    
    /// Replaces the implementation of a method for a given class.
    ///
    /// - Parameters:
    ///   - cls: The class you want to modify.
    ///   - sel: A selector that identifies the method whose implementation you want to replace.
    ///   - targetCls: The class you want to specify.
    ///   - targetSel: The selector of the method you want to retrieve.
    @objc public class func replaceMethod(withClass cls: AnyClass?, selector sel: Selector, targetClass targetCls: AnyClass? = nil, targetSelector targetSel: Selector) {
        
        let _targetCls: AnyClass? = targetCls ?? cls
        guard let imp = class_getMethodImplementation(_targetCls, targetSel) else {
            return
        }
        
        var types: UnsafePointer<Int8>? = nil
        let method = class_getInstanceMethod(_targetCls, targetSel)
        if let m = method {
            types = method_getTypeEncoding(m)
        }
        
        class_replaceMethod(cls, sel, imp, types)
    }
    
    /// Describes the properties declared by a class.
    ///
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the properties.
    @objc public class func propertyList(withClass cls: AnyClass?) -> [String] {
        var names: [String] = [String]()
        
        var count: UInt32 = 0
        let pList = class_copyPropertyList(cls, &count)
        
        for index in 0..<Int(count) {
            
            let p: objc_property_t = pList![index]
            let name = String(cString: property_getName(p))
            names.append(name)
        }
        
        return names
    }
    
    /// Gets the swift namespace from the bundle’s Info.plist file.
    ///
    /// - Returns: A string object.
    public class func swiftNamespace() -> String? {
        // The name of the executable in this bundle (if any).
        let executableKey = kCFBundleExecutableKey as String
        //A dictionary, constructed from the bundle’s Info.plist file.
        let infoDict = Bundle.main.infoDictionary ?? [String : Any]()
        
        // Fetches the value for a key.
        guard let namespace = infoDict[executableKey] as? String else {
            return nil
        }
        
        return namespace
    }
    
    /// Converts a dictionary whose elements are key-value pairs to a corresponding object.
    ///
    /// - Parameters:
    ///   - dictionary: A collection whose elements are key-value pairs.
    ///   - cls: A class that inherits the NSObject class.
    /// - Returns: A corresponding object.
    public class func model<T: NSObject>(withDictionary dictionary: Dictionary<String, Any>?, forClass cls: T.Type?) -> T? {
        
        // Gets the swift namespace.
        //guard let namespace = swiftNamespace() else {
        //    return nil
        //}
        
        //let className = String(cString: class_getName(cls))
        //if  className.isEmpty { return nil }
        
        //let clsName = "\(namespace).\(className)"
        //print("clsName: \(clsName)")
        
        //let aCls: AnyClass? = NSClassFromString(clsName)
        //guard let clsType = aCls as? NSObject.Type else {
        //    return nil
        //}
        //let obj = clsType.init()
        
        guard let clsType = cls else {
            return nil
        }
        let obj = clsType.init()
        
        guard let dict = dictionary else {
            return obj
        }
        
        let pList = propertyList(withClass: cls)
        for (k, v) in dict {
            if pList.contains(k) {
                obj.setValue(v, forKey: k)
            }
        }
        
        return obj
    }
    
    /// Converts a dictionary whose elements are key-value pairs to a corresponding object.
    ///
    /// - Parameters:
    ///   - dictionary: A collection whose elements are key-value pairs.
    ///   - cls: A class that inherits the NSObject class.
    /// - Returns: A corresponding object.
    @objc public class func model(withDictionary dictionary: Dictionary<String, Any>?, usingClass cls: NSObject.Type?) -> AnyObject? {
        
        guard let clsType = cls else {
            return nil
        }
        
        let obj = clsType.init()
        
        guard let dict = dictionary else {
            return obj as AnyObject
        }
        
        let pList = propertyList(withClass: clsType)
        
        for (k, v) in dict {
            if pList.contains(k) {
                obj.setValue(v, forKey: k)
            }
        }
        
        return obj
    }
    
    /// Converts a dictionary whose elements are key-value pairs to a corresponding object.
    ///
    /// - Parameters:
    ///   - dictionary: A collection whose elements are key-value pairs.
    ///   - model: An object that inherits the NSObject class.
    /// - Returns: A corresponding object.
    @objc public class func model(withDictionary dictionary: Dictionary<String, Any>?, usingModel model: NSObject?) -> AnyObject? {
        
        guard let dict = dictionary else {
            return model as AnyObject
        }
        
        guard let obj = model else { return nil }
        
        let cls: AnyClass? = object_getClass(obj)
        let pList = propertyList(withClass: cls)
        
        for (k, v) in dict {
            if pList.contains(k) {
                obj.setValue(v, forKey: k)
            }
        }
        
        return obj
    }
    
    /// Converts a object to a corresponding dictionary whose elements are key-value pairs.
    ///
    /// - Parameter model: A NSObject object.
    /// - Returns: A corresponding dictionary.
    @objc public class func dictionary(withModel model: NSObject?) -> [String: Any]? {
        
        guard let m = model, let cls = object_getClass(m) else {
            return nil
        }
        
        let pList = propertyList(withClass: cls)
        if pList.isEmpty {
            return nil
        }
        
        var dict = [String : Any]()
        
        for key in pList {
            if let value = m.value(forKey: key) {
                dict[key] = value
            }
        }
        
        return dict
    }
    
    /// Encodes an object using a given archiver.
    ///
    /// - Parameters:
    ///   - encoder: An archiver object.
    ///   - obj: An object you want to encode.
    @objc public class func encode(_ encoder: NSCoder, forObject obj: NSObject) {
        
        let ivarNames = ivarList(withClass: obj.classForCoder)
        
        for key in ivarNames {
            let value = obj.value(forKey: key)
            encoder.encode(value, forKey: key)
        }
    }
    
    /// Decodes an object initialized from data in a given unarchiver.
    ///
    /// - Parameters:
    ///   - decoder: An unarchiver object.
    ///   - obj: An object you want to decode.
    @objc public class func decode(_ decoder: NSCoder, forObject obj: NSObject) {
        
        let ivarNames = ivarList(withClass: obj.classForCoder)
        
        for key in ivarNames {
            let value = decoder.decodeObject(forKey: key)
            obj.setValue(value, forKey: key)
        }
    }
    
}
