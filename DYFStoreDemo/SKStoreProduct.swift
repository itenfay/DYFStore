//
//  SKStoreProduct.swift
//
//  Created by Tenfay on 2016/11/28.
//  Copyright © 2016 Tenfay. All rights reserved.
//

import Foundation

open class SKStoreProduct: NSObject {
    
    /// The string that identifies the product.
    public var identifier: String?
    
    /// The name of the product.
    public var name: String?
    
    /// The cost of the product in the local currency.
    public var price: String?
    
    /// The locale price of the product.
    public var localePrice: String?
    
    /// A description of the product.
    public var localizedDescription: String?
    
}
