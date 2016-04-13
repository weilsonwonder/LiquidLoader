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
        self.hidden = false
    }

    public func hide() {
        self.hidden = true
    }
}

public class LiquidLoaderFull : UIView {
    public let textLabel: UILabel
    public let liquidLoader: LiquidLoader
    public var animationDuration: NSTimeInterval = 2
    public var cornerRadius: CGFloat = 12 {
        didSet {
            backgroundView.layer.cornerRadius = cornerRadius
        }
    }
    
    private var addedToKeyWindow: Bool = false
    private let lineDiameterMultiplier: CGFloat = 0.1
    private let circleDiameterMultiplier: CGFloat = 1.0
    private let backgroundView: UIVisualEffectView
    
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
        
        addSubview(backgroundView)
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 20)
        )
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: backgroundView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 20)
        )
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 20)
        )
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: backgroundView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 20)
        )
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        )
        addConstraint(NSLayoutConstraint(
            item: backgroundView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        )
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
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        liquidLoader = LiquidLoader(frame: CGRect(x: 0, y: 0, width: 50, height: 50), effect: Effect.Circle(UIColor.whiteColor()))
        textLabel = UILabel()
        super.init(coder: aDecoder)
        addSubview(liquidLoader)
        liquidLoader.center = center
        liquidLoader.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        addSubview(textLabel)
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.numberOfLines = 0
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tl]-|", options: [], metrics: nil, views: ["tl": textLabel]))
        addConstraint(NSLayoutConstraint(
            item: textLabel,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: liquidLoader,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8)
        )
        addConstraint(NSLayoutConstraint(
            item: textLabel,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.LessThanOrEqual,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8)
        )
        backgroundColor = UIColor(white: 0, alpha: 0.25)
        userInteractionEnabled = true
        hidden = true
        liquidLoader.show()
    }
    
    public func show(text: String?, completion: (Void -> Void)? = nil) {
        if hidden {
            alpha = 0
            hidden = false
        }
        textLabel.text = text
        if superview == nil {
            UIApplication.sharedApplication().keyWindow?.addSubview(self)
            addedToKeyWindow = true
        }
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            options: [UIViewAnimationOptions.AllowAnimatedContent, UIViewAnimationOptions.BeginFromCurrentState],
            animations: {
                self.alpha = 1
            },
            completion: { _ in
                completion?()
        })
    }
    
    public func hide(completion: (Void -> Void)? = nil) {
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            options: [UIViewAnimationOptions.AllowAnimatedContent, UIViewAnimationOptions.BeginFromCurrentState],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                self.hidden = true
                if self.addedToKeyWindow {
                    self.removeFromSuperview()
                }
                completion?()
        })
    }
    
    public func changeLoadingText(text: String?) {
        textLabel.text = text
        layoutIfNeeded()
    }
}

