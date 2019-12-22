//
//  DYFLoadingView.swift
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

/// Creates and returns a color object using the specified opacity and RGB component values.
///
/// - Parameters:
///   - r: The red value of the color object, specified as a value from 0.0 to 255.0.
///   - g: The green value of the color object, specified as a value from 0.0 to 255.0.
///   - b: The blue value of the color object, specified as a value from 0.0 to 255.0.
///   - alp: The opacity value of the color object, specified as a value from 0.0 to 1.0.
/// - Returns: The color object. The color information represented by this object is in an RGB colorspace.
public func COLOR_RGBA(_ r: CGFloat,
                       _ g: CGFloat,
                       _ b: CGFloat,
                       _ alp: CGFloat) -> UIColor {
    
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alp)
}

/// Creates and returns a color object using the specified opacity and RGB component values.
///
/// - Parameters:
///   - r: The red value of the color object, specified as a value from 0.0 to 255.0.
///   - g: The green value of the color object, specified as a value from 0.0 to 255.0.
///   - b: The blue value of the color object, specified as a value from 0.0 to 255.0.
/// - Returns: The color object. The color information represented by this object is in an RGB colorspace.
public func COLOR_RGB(_ r: CGFloat,
                      _ g: CGFloat,
                      _ b: CGFloat) -> UIColor {
    
    return COLOR_RGBA(r, g, b, 1.0)
}

/// Returns the width of the screen for the device.
public let SCREEN_W = UIScreen.main.bounds.size.width

/// Returns the height of the screen for the device.
public let SCREEN_H = UIScreen.main.bounds.size.height

open class DYFLoadingView: UIView {
    
    /// The text to prompt the user.
    public var text: String?
    
    private lazy var maskPanel: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_RGBA(20, 20, 20, 0.5)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_RGB(255, 255, 255)
        return view
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.color = COLOR_RGB(60, 60, 60)
        return indicator
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = COLOR_RGB(60, 60, 60)
        return label
    }()
    
    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    public func show(_ text: String) {
        self.text = text
        self.showWithAnimation()
    }
    
    public func hide() {
        
        if self.indicatorView.isAnimating {
            self.indicatorView.stopAnimating()
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.removeAllViews()
        }
    }
    
    private func removeAllViews() {
        let window = keyWindow() ?? UIApplication.shared.windows[0]
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        for view in window.subviews {
            if view.isKind(of: DYFLoadingView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    private func showWithAnimation() {
        
        let window = keyWindow() ?? UIApplication.shared.windows[0]
        self.addSubview(maskPanel)
        window.addSubview(self)
        
        self.maskPanel.addSubview(contentView)
        self.contentView.addSubview(indicatorView)
        self.indicatorView.startAnimating()
        
        self.textLabel.text = text
        self.textLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.textLabel.textAlignment = NSTextAlignment.center
        self.textLabel.numberOfLines = 1
        self.contentView.addSubview(textLabel)
        
        self.layoutIfNeeded()
        
        self.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
        }
    }
    
    open override func layoutSubviews() {
        
        self.frame = CGRect(x: 0, y: 0, width: SCREEN_W, height: SCREEN_H)
        self.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue  | UIView.AutoresizingMask.flexibleWidth.rawValue      | UIView.AutoresizingMask.flexibleHeight.rawValue
        )
        
        let sw = self.bounds.size.width
        let sh = self.bounds.size.height
        
        self.maskPanel.frame = CGRect(x: 0, y: 0, width: sw, height: sh)
        self.maskPanel.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue  | UIView.AutoresizingMask.flexibleWidth.rawValue      | UIView.AutoresizingMask.flexibleHeight.rawValue
        )
        
        let cw = 260.0
        let ch = 130.0
        self.contentView.center = CGPoint(x: cw/2, y: ch/2)
        self.contentView.bounds = CGRect(x: 0, y: 0, width: cw, height: ch)
        self.contentView.setCorner(radius: 10.0)
        
        self.indicatorView.center = CGPoint(x: cw/2, y: ch/2 - 10)
        self.textLabel.frame = CGRect(x: 10, y: ch - 20 - 15, width: cw - 20, height: 20)
    }
    
    deinit {
        #if DEBUG
        print("\(#function)")
        #endif
    }
}
