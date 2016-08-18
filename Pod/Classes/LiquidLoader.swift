//
//  LiquidLoader.swift
//  LiquidLoading
//
//  Created by Takuma Yoshida on 2015/08/24.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

public enum Effect {
    case Line(UIColor)
    case Circle(UIColor)
    case GrowLine(UIColor)
    case GrowCircle(UIColor)
    
    func setup(loader: LiquidLoader) -> LiquidLoadEffect {
        switch self {
        case .Line(let color):
            return LiquidLineEffect(loader: loader, color: color)
        case .Circle(let color):
            return LiquidCircleEffect(loader: loader, color: color)
        case .GrowLine(let color):
            let line = LiquidLineEffect(loader: loader, color: color)
            line.isGrow = true
            return line
        case .GrowCircle(let color):
            let circle = LiquidCircleEffect(loader: loader, color: color)
            circle.isGrow = true
            return circle
        }
    }
}

public class LiquidLoader : UIView {
    private let effect: Effect
    private var effectDelegate: LiquidLoadEffect?

    public init(frame: CGRect, effect: Effect) {
        self.effect = effect
        super.init(frame: frame)
        self.hidden = true
        self.userInteractionEnabled = false
        self.effectDelegate = self.effect.setup(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.effect = .Circle(UIColor.whiteColor())
        super.init(coder: aDecoder)
        self.hidden = true
        self.userInteractionEnabled = false
        self.effectDelegate = self.effect.setup(self)
    }

    public func show() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.hidden = false
        }
    }

    public func hide() {
        dispatch_async(dispatch_get_main_queue()) {
            self.hidden = true
        }
    }
}

public class LiquidLoaderFull : UIView, UIDynamicAnimatorDelegate {
    
    private var animator: UIDynamicAnimator!
    private var centerXConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    
    public let textLabel: UILabel
    public let liquidLoader: LiquidLoader
    public var animationDuration: NSTimeInterval = 3
    public var cornerRadius: CGFloat = 12 {
        didSet {
            backgroundView.layer.cornerRadius = cornerRadius
        }
    }
    
    private let backgroundView: UIVisualEffectView
    private var addedToKeyWindow: Bool = false
    private let lineDiameterMultiplier: CGFloat = 0.1
    private let circleDiameterMultiplier: CGFloat = 1.0
    
    private var completion: (() -> Void)?
    private var isShow: Bool = true
    
    public convenience init(width: CGFloat, effect: Effect) {
        self.init(width: width, effect: effect, style: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    }
    
    public init(width: CGFloat, effect: Effect, style: UIVisualEffect) {
        backgroundView = UIVisualEffectView(effect: style)
        var liquidLoaderHeight: CGFloat = width
        switch effect {
        case .Line(_):
            liquidLoaderHeight = width * lineDiameterMultiplier
        case .Circle(_):
            liquidLoaderHeight = width * circleDiameterMultiplier
        case .GrowLine(_):
            liquidLoaderHeight = width * lineDiameterMultiplier
        case .GrowCircle(_):
            liquidLoaderHeight = width * circleDiameterMultiplier
        }
        
        liquidLoader = LiquidLoader(frame: CGRect(x: 0, y: 0, width: width, height: liquidLoaderHeight), effect: effect)
        textLabel = UILabel()
        super.init(frame: UIScreen.mainScreen().bounds)
        
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        
        addSubview(backgroundView)
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint = NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0
        )
        centerXConstraint = NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0
        )
        let topC = NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 20
        )
        let bottomC = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: backgroundView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 20
        )
        topC.priority = UILayoutPriorityDefaultHigh
        bottomC.priority = UILayoutPriorityDefaultHigh
        addConstraint(topC)
        addConstraint(bottomC)
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 20
            ))
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: backgroundView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 20
            ))
        addConstraint(centerXConstraint)
        addConstraint(centerYConstraint)
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: width + 40)
        )
        
        backgroundView.addSubview(liquidLoader)
        backgroundView.frame = CGRect(x: 0, y: 0, width: width + 40, height: liquidLoaderHeight + 100)
        liquidLoader.frame = CGRect(x: 20, y: 20, width: width, height: liquidLoaderHeight)
        liquidLoader.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        
        backgroundView.addSubview(textLabel)
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.whiteColor()
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tl]-|", options: [], metrics: nil, views: ["tl": textLabel]))
        backgroundView.addConstraint(NSLayoutConstraint(
            item: textLabel,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: liquidLoader,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8)
        )
        backgroundView.addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: textLabel,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 20)
        )
        
        backgroundColor = UIColor(white: 0, alpha: 0.25)
        autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        userInteractionEnabled = true
        hidden = true
        liquidLoader.show()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let width: CGFloat = 140
        let effect = Effect.Line(UIColor.whiteColor())
        let style = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        
        backgroundView = UIVisualEffectView(effect: style)
        let liquidLoaderHeight: CGFloat = width * lineDiameterMultiplier
        
        liquidLoader = LiquidLoader(frame: CGRect(x: 0, y: 0, width: width, height: liquidLoaderHeight), effect: effect)
        textLabel = UILabel()
        super.init(frame: UIScreen.mainScreen().bounds)
        
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        
        addSubview(backgroundView)
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint = NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0
        )
        centerXConstraint = NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0
        )
        let topC = NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 20
        )
        let bottomC = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: backgroundView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 20
        )
        topC.priority = UILayoutPriorityDefaultHigh
        bottomC.priority = UILayoutPriorityDefaultHigh
        addConstraint(topC)
        addConstraint(bottomC)
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 20
            ))
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: backgroundView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 20
            ))
        addConstraint(centerXConstraint)
        addConstraint(centerYConstraint)
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: width + 40)
        )
        
        backgroundView.addSubview(liquidLoader)
        backgroundView.frame = CGRect(x: 0, y: 0, width: width + 40, height: liquidLoaderHeight + 100)
        liquidLoader.frame = CGRect(x: 20, y: 20, width: width, height: liquidLoaderHeight)
        liquidLoader.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        
        backgroundView.addSubview(textLabel)
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.whiteColor()
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tl]-|", options: [], metrics: nil, views: ["tl": textLabel]))
        backgroundView.addConstraint(NSLayoutConstraint(
            item: textLabel,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: liquidLoader,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8)
        )
        backgroundView.addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: textLabel,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 20)
        )
        
        backgroundColor = UIColor(white: 0, alpha: 0.25)
        autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        userInteractionEnabled = true
        hidden = true
        liquidLoader.show()
    }
    
    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
        if !isShow {
            hidden = true
            if addedToKeyWindow {
                removeFromSuperview()
                addedToKeyWindow = false
            }
        }
        completion?()
    }
    
    public func show(text: String?, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            self.completion = completion
            self.isShow = true
            
            self.hidden = false
            self.textLabel.text = text
            
            if self.superview == nil {
                UIApplication.sharedApplication().keyWindow?.addSubview(self)
                self.translatesAutoresizingMaskIntoConstraints = false
                UIApplication.sharedApplication().keyWindow?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[s]|", options: [], metrics: nil, views: ["s": self]))
                UIApplication.sharedApplication().keyWindow?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[s]|", options: [], metrics: nil, views: ["s": self]))
                self.addedToKeyWindow = true
            }
            
            let dynamicHub = DynamicHub()
            dynamicHub.center = CGPoint(x: 0, y: 40)
            
            let snapBehavior = UISnapBehavior(item: dynamicHub, snapToPoint: CGPoint.zero)
            snapBehavior.damping = 0.25
            snapBehavior.action = {
                self.centerYConstraint.constant = -dynamicHub.center.y
            }
            
            self.animator.addBehavior(snapBehavior)
        }
    }
    
    public func hide(completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.completion = completion
            self.isShow = false
            self.dynamicAnimatorDidPause(self.animator)
        }
    }
    
    public func changeLoadingText(text: String?) {
        textLabel.text = text
        layoutIfNeeded()
    }
}

class DynamicHub: NSObject, UIDynamicItem {
    var center: CGPoint
    var bounds: CGRect
    var transform: CGAffineTransform
    
    override init() {
        bounds = UIScreen.mainScreen().bounds
        center = CGPoint(x: 50, y: 50)
        transform = CGAffineTransformIdentity
        super.init()
    }
}

