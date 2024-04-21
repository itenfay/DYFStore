//
//  SKIndefiniteAnimatedSpinner.swift
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

public class SKIndefiniteAnimatedSpinner: UIView {
    
    /// A structure is named "AnimationKey".
    private struct AnimationKey {
        static let stroke   = "spinner.animkey.stroke"
        static let rotation = "spinner.animkey.rotation"
    }
    
    /// The property indicates whether the view is currently animating.
    public private(set) var isAnimating: Bool = false
    
    /// Sets whether the view is hidden when not animating.
    public var hidesWhenStopped: Bool = true
    
    /// Specifies the timing function to use for the control's animation. Defaults to kCAMediaTimingFunctionEaseInEaseOut.
    public var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    /// A layer that draws a arc progress in its coordinate space.
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = nil
        layer.fillColor   = nil
        layer.lineWidth   = 1.0
        return layer
    }()
    
    /// Sets the line width of the spinner's circle.
    public var lineWidth: CGFloat {
        get {
            return self.progressLayer.lineWidth
        }
        set {
            self.progressLayer.lineWidth = newValue
            self.updatePath()
        }
    }
    
    /// Sets the line color of the spinner's circle.
    public var lineColor: UIColor? {
        get {
            guard let color = self.progressLayer.strokeColor else {
                return nil
            }
            return UIColor.init(cgColor: color)
        }
        set (newColor) {
            self.progressLayer.strokeColor = newColor?.cgColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Supports an Interface Builder archive, or nib file.
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.layer.addSublayer(self.progressLayer)
        let selector = #selector(resetAnimations)
        let name = UIApplication.didBecomeActiveNotification
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    /// Starts animation of the spinner.
    public func startAnimating() {
        if self.isAnimating {
            return
        }
        self.isAnimating = true
        self.addLayerAnimations()
        self.isHidden = false
    }
    
    /// Stops animation of the spinnner.
    public func stopAnimating() {
        if !self.isAnimating {
            return
        }
        self.isAnimating = false
        self.progressLayer.removeAnimation(forKey: AnimationKey.rotation)
        self.progressLayer.removeAnimation(forKey: AnimationKey.stroke)
        
        if self.hidesWhenStopped {
            self.isHidden = true
        }
    }
    
    private func addLayerAnimations() {
        let animation                   = CABasicAnimation()
        animation.keyPath               = "transform.rotation"
        animation.duration              = 2.0
        animation.fromValue             = NSNumber(value: 0.0)
        animation.toValue               = NSNumber(value: 2*Double.pi)
        animation.repeatCount           = Float.infinity
        self.progressLayer.add(animation, forKey: AnimationKey.rotation)
        
        let headAnimation               = CABasicAnimation()
        headAnimation.keyPath           = "strokeStart"
        headAnimation.duration          = 1.0
        headAnimation.fromValue         = NSNumber(value: 0.0)
        headAnimation.toValue           = NSNumber(value: 0.25)
        headAnimation.timingFunction    = self.timingFunction
        
        let tailAnimation               = CABasicAnimation()
        tailAnimation.keyPath           = "strokeEnd"
        tailAnimation.duration          = 1.0
        tailAnimation.fromValue         = NSNumber(value: 0.0)
        tailAnimation.toValue           = NSNumber(value: 1.0)
        tailAnimation.timingFunction    = self.timingFunction
        
        let endHeadAnimation            = CABasicAnimation()
        endHeadAnimation.keyPath        = "strokeStart"
        endHeadAnimation.beginTime      = 1.0
        endHeadAnimation.duration       = 0.5
        endHeadAnimation.fromValue      = NSNumber(value: 0.25)
        endHeadAnimation.toValue        = NSNumber(value: 1.0)
        endHeadAnimation.timingFunction = self.timingFunction
        
        let endTailAnimation            = CABasicAnimation()
        endTailAnimation.keyPath        = "strokeEnd"
        endTailAnimation.beginTime      = 1.0
        endTailAnimation.duration       = 0.5
        endTailAnimation.fromValue      = NSNumber(value: 1.0)
        endTailAnimation.toValue        = NSNumber(value: 1.0)
        endTailAnimation.timingFunction = self.timingFunction
        
        let animGroup                   = CAAnimationGroup()
        animGroup.repeatCount           = Float.infinity
        animGroup.duration              = 1.5
        animGroup.animations            = [headAnimation,
                                           tailAnimation,
                                           endHeadAnimation,
                                           endTailAnimation]
        self.progressLayer.add(animGroup, forKey: AnimationKey.stroke)
    }
    
    @objc private func resetAnimations() {
        if self.isAnimating {
            self.stopAnimating()
            self.startAnimating()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let sW = self.bounds.size.width
        let sH = self.bounds.size.height
        self.progressLayer.frame = CGRect(x: 0, y: 0, width: sW, height: sH)
        
        self.updatePath()
    }
    
    private func updatePath() {
        let sW = self.bounds.size.width
        let sH = self.bounds.size.height
        
        let center     = CGPoint(x: sW/2, y: sH/2)
        let radius     = min(sW/2, sH/2) - self.lineWidth/2
        let startAngle = CGFloat(0.0)
        let endAngle   = CGFloat(2*Double.pi)
        
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        self.progressLayer.path = path.cgPath
        
        self.progressLayer.strokeStart = 0.0
        self.progressLayer.strokeEnd   = 0.0
    }
    
    private func executeWhenReleasing() {
        self.stopAnimating()
        let name = UIApplication.didBecomeActiveNotification
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
    
    deinit {
        #if DEBUG
        print("\(type(of: self)) deinit.")
        #endif
        self.executeWhenReleasing()
    }
    
}
