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
    public let liquidLoader: LiquidLoader
    public var animationDuration: NSTimeInterval = 0.3
    
    private var addedToKeyWindow: Bool = false
    
    public init(size: CGSize, effect: Effect) {
        liquidLoader = LiquidLoader(frame: CGRect(origin: CGPoint.zero, size: size), effect: effect)
        super.init(frame: UIScreen.mainScreen().bounds)
        addSubview(liquidLoader)
        liquidLoader.center = center
        liquidLoader.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        backgroundColor = UIColor(white: 0, alpha: 0.25)
        autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        userInteractionEnabled = true
        hidden = true
        liquidLoader.show()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        liquidLoader = LiquidLoader(frame: CGRect(x: 0, y: 0, width: 50, height: 50), effect: Effect.Circle(UIColor.whiteColor()))
        super.init(coder: aDecoder)
        addSubview(liquidLoader)
        liquidLoader.center = center
        liquidLoader.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        backgroundColor = UIColor(white: 0, alpha: 0.25)
        userInteractionEnabled = true
        hidden = true
        liquidLoader.show()
    }
    
    public func show(completion: (Void -> Void)? = nil) {
        if hidden {
            alpha = 0
            hidden = false
        }
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
}

