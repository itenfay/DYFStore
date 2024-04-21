//
//  SKExtensions.swift
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

import Foundation
import UIKit

fileprivate var LoadingViewKey = "LoadingViewKey"

extension NSObject {
    
    /// The app's key window.
    public var sk_keyWindow: UIWindow? {
        var keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?.windows
                .filter({ $0.isKeyWindow }).first
        } else {
            keyWindow = UIApplication.shared.windows
                .filter({ $0.isKeyWindow }).first
        }
        return keyWindow
    }
    
    /// Returns The view controller associated with the currently visible view.
    ///
    /// - Returns: The view controller associated with the currently visible view.
    public func sk_currentViewController()  -> UIViewController? {
        let viewController = sk_keyWindow?.rootViewController
        return sk_findCurrentViewController(from: viewController)
    }
    
    private func sk_findCurrentViewController(from viewController: UIViewController?) -> UIViewController? {
        guard var vc = viewController else { return nil }
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
    
    /// Shows the tips for user.
    public func sk_showTipsMessage(_ message: String) -> Void {
        guard let vc = self.sk_currentViewController() , !vc.isKind(of: UIAlertController.self) else {
            return
        }
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        vc.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Shows an alert view controller.
    public func sk_showAlert(withTitle title: String?,
                             message: String?,
                             cancelButtonTitle: String? = nil,
                             cancel cancelHandler: ((UIAlertAction) -> Void)? = nil,
                             confirmButtonTitle: String?,
                             execute executableHandler: ((UIAlertAction) -> Void)? = nil) {
        guard let vc = self.sk_currentViewController()  else {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if let t = cancelButtonTitle, t.count > 0 {
            let action = UIAlertAction(title: t, style: UIAlertAction.Style.cancel, handler: cancelHandler)
            alertController.addAction(action)
        }
        
        if let t = confirmButtonTitle, t.count > 0 {
            let action = UIAlertAction(title: t, style: UIAlertAction.Style.default, handler: executableHandler)
            alertController.addAction(action)
        }
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    /// Shows a loading panel.
    public func sk_showLoading(_ text: String) {
        let value = objc_getAssociatedObject(self, &LoadingViewKey)
        if value != nil {
            return
        }
        let loadingView = SKLoadingView()
        loadingView.show(text)
        loadingView.color = COLOR_RGBA(10, 10, 10, 0.75)
        loadingView.indicatorColor = COLOR_RGB(54, 205, 64)
        loadingView.textColor = COLOR_RGB(248, 248, 248)
        objc_setAssociatedObject(self, &LoadingViewKey, loadingView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Hides a loading panel.
    public func sk_hideLoading() {
        let value = objc_getAssociatedObject(self, &LoadingViewKey)
        guard let loadingView = value as? SKLoadingView else {
            return
        }
        loadingView.hide()
        objc_setAssociatedObject(self, &LoadingViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}

extension UIView {
    
    /// This method is used to set the corner.
    ///
    /// - Parameters:
    ///   - rectCorner: The corners of a rectangle.
    ///   - radius: The radius of each corner.
    public func sk_setCorner(rectCorner: UIRectCorner = UIRectCorner.allCorners, radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        let w = self.bounds.size.width
        let h = self.bounds.size.height
        maskLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: radius, height: radius))
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
    
    /// This method is used to set the border.
    ///
    /// - Parameters:
    ///   - rectCorner: The corners of a rectangle.
    ///   - radius: The radius of each corner.
    ///   - lineWidth: Specifies the line width of the shape’s path.
    ///   - color: The color used to stroke the shape’s path.
    public func sk_setBorder(rectCorner: UIRectCorner = UIRectCorner.allCorners, radius: CGFloat, lineWidth: CGFloat, color: UIColor?) {
        let maskLayer = CAShapeLayer()
        let w = self.bounds.size.width
        let h = self.bounds.size.height
        maskLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        borderLayer.lineWidth = lineWidth
        borderLayer.strokeColor = color?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: radius, height: radius))
        borderLayer.path = path.cgPath
        maskLayer.path = path.cgPath
        
        self.layer.insertSublayer(borderLayer, at: 0)
        self.layer.mask = maskLayer
    }
    
}
