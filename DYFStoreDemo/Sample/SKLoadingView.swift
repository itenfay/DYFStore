//
//  SKLoadingView.swift
//
//  Created by Teng Fei on 2016/11/28.
//  Copyright © 2016 Teng Fei. All rights reserved.
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

public class SKLoadingView: UIView {
    
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
    private lazy var indicator: SKIndefiniteAnimatedSpinner = {
        let spinner = SKIndefiniteAnimatedSpinner()
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
        self.autoresizingMask = UIView.AutoresizingMask(rawValue:
            UIView.AutoresizingMask.flexibleLeftMargin.rawValue |
            UIView.AutoresizingMask.flexibleTopMargin.rawValue  |
            UIView.AutoresizingMask.flexibleWidth.rawValue      |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        )
        
        self.maskPanel.autoresizingMask = UIView.AutoresizingMask(rawValue:
            UIView.AutoresizingMask.flexibleLeftMargin.rawValue |
            UIView.AutoresizingMask.flexibleTopMargin.rawValue  |
            UIView.AutoresizingMask.flexibleWidth.rawValue      |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        )
        
        var cW: CGFloat = 0.0
        var cH: CGFloat = 0.0
        let iW: CGFloat = 36.0
        let offset: CGFloat = 15.0
        
        self.textLabel.text = text
        self.textLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        self.textLabel.textAlignment = NSTextAlignment.center
        self.textLabel.numberOfLines = 1
        self.textLabel.sizeToFit()
        let textSize = self.textLabel.bounds.size
        
        cW = textSize.width + 2*offset
        cW = cW > (SCREEN_W - 40) ? (SCREEN_W - 40) : cW
        cW = cW < (iW + 4*offset) ? (iW + 4*offset) : cW
        cH = textSize.height + iW + 3*offset
        self.contentView.frame = CGRect(x: 0, y: 0, width: cW, height: cH)
        self.contentView.sk_setCorner(radius: 10.0)
        
        let iX: CGFloat = cW/2 - iW/2
        var iY: CGFloat = cH/2 - iW + 5.0
        if self.textLabel.text?.isEmpty == true {
            iY = cH/2 - iW/2
        }
        self.indicator.frame = CGRect(x: iX, y: iY, width: iW, height: iW)
        self.indicator.lineWidth = 2.0
        
        self.textLabel.frame = CGRect(x: offset, y: CGRectGetMaxY(self.indicator.frame) + offset, width: cW - 2*offset, height: textSize.height)
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
        var sW: CGFloat = 0.0
        var sH: CGFloat = 0.0
        
        if let supv = self.superview {
            sW = supv.bounds.size.width
            sH = supv.bounds.size.height
        } else {
            sW = SCREEN_W
            sH = SCREEN_H
        }
        self.frame = CGRect(x: 0, y: 0, width: sW, height: sH)
        
        self.maskPanel.frame = CGRect(x: 0, y: 0, width: sW, height: sH)
        self.contentView.center = CGPoint(x: sW/2, y: sH/2)
    }
    
    deinit {
        #if DEBUG
        print("\(type(of: self)) deinit.")
        #endif
    }
    
}
