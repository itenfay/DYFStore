//
//  DYFLoadingView.swift
//
//  Created by dyf on 2016/11/28. ( https://github.com/dgynfi/DYFStore )
//  Copyright © 2016 dyf. All rights reserved.
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

public class DYFLoadingView: UIView {
    
    /// It is used to act as background mask panel.
    private lazy var maskPanel: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_RGBA(20, 20, 20, 0.5)
        return view
    }()
    
    /// It is used to render the content.
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_RGB(255, 255, 255)
        return view
    }()
    
    /// The spinner is used to provide an indefinite animation.
    private lazy var indicator: DYFIndefiniteAnimatedSpinner = {
        let spinner = DYFIndefiniteAnimatedSpinner()
        spinner.backgroundColor = UIColor.clear
        spinner.lineColor = COLOR_RGB(100, 100, 100)
        return spinner
    }()
    
    /// It is used to show the text.
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = COLOR_RGB(60, 60, 60)
        return label
    }()
    
    /// Returns the current window of the app.
    private func appWindow() -> UIWindow {
        let sharedApp = UIApplication.shared
        return sharedApp.keyWindow ?? sharedApp.windows[0]
    }
    
    /// The color to set the background color of the content view.
    public var color: UIColor? {
        get {
            return self.contentView.backgroundColor
        }
        
        set {
            self.contentView.backgroundColor = newValue
        }
    }
    
    /// The color to set the line color of the indicator.
    public var indicatorColor: UIColor? {
        get {
            return self.indicator.lineColor
        }
        
        set {
            self.indicator.lineColor = newValue
        }
    }
    
    /// The color to set the text color of the text label.
    public var textColor: UIColor? {
        get {
            return self.textLabel.textColor
        }
        
        set (newColor) {
            self.textLabel.textColor = newColor
        }
    }
    
    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    /// - Parameter frame: The frame rectangle for the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Returns an object initialized from data in a given unarchiver.
    /// - Parameter coder: An unarchiver object.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        // Prepares the receiver for service after it has been loaded
        // from an Interface Builder archive, or nib file.
    }
    
    /// It will be displayed on the screen with the text.
    /// - Parameter text: The text to prompt the user.
    public func show(_ text: String) {
        self.configure(text)
        self.loadView()
        self.beginAnimating()
    }
    
    /// Configures properties for the widget used.
    private func configure(_ text: String) {
        self.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue |
            UIView.AutoresizingMask.flexibleTopMargin.rawValue  |
            UIView.AutoresizingMask.flexibleWidth.rawValue      |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        )
        
        self.maskPanel.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue |
            UIView.AutoresizingMask.flexibleTopMargin.rawValue  |
            UIView.AutoresizingMask.flexibleWidth.rawValue      |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        )
        
        let cw = 200.0
        self.contentView.frame = CGRect(x: 0, y: 0, width: cw, height: 0.6*cw)
        self.contentView.setCorner(radius: 10.0)
        
        let offset = 10.0
        let iw = 60.0
        let ix = cw/2 - iw/2
        let iy = 1.5*offset
        self.indicator.frame = CGRect(x: ix, y: iy, width: iw, height: iw)
        self.indicator.lineWidth = 2.0
        
        let lh = 20.0
        self.textLabel.center = CGPoint(x: cw/2, y: 0.6*cw - lh/2 - 1.5*offset)
        self.textLabel.bounds = CGRect(x: 0, y: 0, width: cw - 2*offset, height: lh)
        self.textLabel.text = text
        self.textLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.textLabel.textAlignment = NSTextAlignment.center
        self.textLabel.numberOfLines = 1
    }
    
    /// Addds the subviews to its corresponding superview.
    private func loadView() {
        if let vc = self.appCurrentViewController() {
            
            vc.view.addSubview(self)
            vc.view.bringSubviewToFront(self)
            
        } else {
            
            let window = self.appWindow()
            window.addSubview(self)
            window.bringSubviewToFront(self)
        }
        
        self.addSubview(self.maskPanel)
        
        self.addSubview(self.contentView)
        self.bringSubviewToFront(self.contentView)
        
        self.contentView.addSubview(self.indicator)
        self.contentView.addSubview(self.textLabel)
    }
    
    /// Prepares to begin animating.
    private func beginAnimating() {
        self.indicator.startAnimating()
        
        self.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    /// Hides from its own superview.
    public func hide() {
        let opts = UIView.AnimationOptions.curveEaseInOut
        
        UIView.animate(withDuration: 0.3, delay: 1.0, options: opts, animations: {
            
            self.alpha = 0.0
            
        }) { (finished) in
            
            self.indicator.stopAnimating()
            self.removeAllViews()
        }
    }
    
    /// Removes all views at the end of the hidden animation.
    private func removeAllViews() {
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.removeFromSuperview()
    }
    
    /// Finds out the current view controller.
    private func appCurrentViewController() -> UIViewController? {
        
        guard var vc = self.appWindow().rootViewController else {
            return nil
        }
        
        while true {
            if let tvc = vc.presentedViewController {
                vc = tvc
            } else if vc.isKind(of: UITabBarController.self) {
                
                let tbc = vc as! UITabBarController
                if let tvc = tbc.selectedViewController {
                    vc = tvc
                }
            } else if vc.isKind(of: UINavigationController.self) {
                
                let nc = vc as! UINavigationController
                if let tvc = nc.visibleViewController {
                    vc = tvc
                }
            } else {
                
                if vc.children.count > 0 {
                    if let tvc = vc.children.last {
                        vc = tvc
                    }
                }
                break
            }
        }
        
        return vc
    }
    
    public override func layoutSubviews() {
        var self_w: CGFloat = 0.0
        var self_h: CGFloat = 0.0
        
        if let supv = self.superview {
            
            self_w = supv.bounds.size.width
            self_h = supv.bounds.size.height
            
        } else {
            
            self_w = SCREEN_W
            self_h = SCREEN_H
        }
        self.frame = CGRect(x: 0, y: 0, width: self_w, height: self_h)
        
        self.maskPanel.frame = CGRect(x: 0, y: 0, width: self_w, height: self_h)
        self.contentView.center = CGPoint(x: self_w/2, y: self_h/2)
    }
    
    deinit {
        #if DEBUG
        print("[\((#file as NSString).lastPathComponent):\(#function)]")
        #endif
    }
    
}
