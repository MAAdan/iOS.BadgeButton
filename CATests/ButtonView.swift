//
//  ButtonView.swift
//  CATests
//
//  Created by Miguel Angel Adan Roman on 1/2/19.
//  Copyright © 2019 Avantiic. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension CGFloat {
    static var outerCircleRatio: CGFloat = 0.8
    static var innerCircleRatio: CGFloat = 0.55
    static var inProgressRatio: CGFloat = 0.58
}

fileprivate extension Double {
    static var animationDuration: Double = 0.5
    static var inProgressPeriod: Double = 2.0
}


class ButtonView: UIView {
    enum State {
        case off
        case inProgress
        case on
    }
    
    public var state: State = .off {
        didSet {
            switch state {
            case .on:
                showInProgress(false)
                animateTo(.on)
            case .off:
                showInProgress(false)
                animateTo(.off)
            case .inProgress:
                showInProgress(true)
            }
        }
    }
    
    private let buttonLayer = CALayer()
    
    private lazy var innerCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = Utils.pathForCircleInRect(rect: buttonLayer.bounds, scaled: CGFloat.innerCircleRatio)
        layer.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.strokeColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        layer.lineWidth = 3
        
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 15, height: 10)
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return layer
    }()
    
    private lazy var outerCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = Utils.pathForCircleInRect(rect: buttonLayer.bounds, scaled: CGFloat.outerCircleRatio)
        layer.fillColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        layer.opacity = 0.4
        return layer
    }()
    
    private lazy var badgeLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [#colorLiteral(red: 0.9198423028, green: 0.9198423028, blue: 0.9198423028, alpha: 1), #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)].map{ $0.cgColor }
        layer.frame = self.layer.bounds
        layer.mask = createBadgeMaskLayer()
        return layer
    }()
    
    private lazy var inProgressLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), UIColor(white: 1, alpha: 0)].map({ (color) -> CGColor in
            return color.cgColor
        })
        
        layer.frame = CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(CGFloat.inProgressRatio))
        layer.locations = [0, 0.7].map({ location -> NSNumber in
            NSNumber(floatLiteral: location)
        })
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: layer.bounds).cgPath
        layer.mask = mask
        
        layer.isHidden = true
        
        return layer
    }()
    
    private lazy var animatedBackground: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = Utils.pathForCircleInRect(rect: buttonLayer.frame, scaled: CGFloat.innerCircleRatio)
        layer.fillColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        layer.mask = createBadgeMaskLayer()
        return layer
    }()
    
    private func showInProgress(_ show: Bool = true) {
        if show {
            inProgressLayer.isHidden = false
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = 2 * Double.pi
            animation.duration = Double.inProgressPeriod
            animation.repeatCount = .greatestFiniteMagnitude
            inProgressLayer.add(animation, forKey: "inProgressAnimation")
        } else {
            inProgressLayer.isHidden = true
            inProgressLayer.removeAnimation(forKey: "inProgressAnimation")
        }
    }
    
    private func createBadgeMaskLayer() -> CAShapeLayer {
        let mask = CAShapeLayer()
        mask.path = UIBezierPath.badgePath.cgPath
        let scaleWidth = self.layer.bounds.width / UIBezierPath.badgePath.bounds.width
        let scaleHeight = self.layer.bounds.height / UIBezierPath.badgePath.bounds.height
        mask.transform = CATransform3DMakeScale(scaleWidth, scaleHeight, 1)
        
        return mask
    }
    
    func animateTo(_ state: State) {
        let animationKey: String
        let path: CGPath
        
        switch state {
        case .on:
            path = Utils.pathForCircleThatContains(rect: bounds)
            animationKey = "onAnimation"
        case .off:
            path = Utils.pathForCircleInRect(rect: buttonLayer.frame, scaled: CGFloat.innerCircleRatio)
            animationKey = "offAnumation"
        default:
            animationKey = ""
            path = UIBezierPath().cgPath
        }
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = animatedBackground.path
        animation.toValue = path
        animation.duration = Double.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        animatedBackground.add(animation, forKey: animationKey)
        animatedBackground.path = path
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayers()
    }
    
    private func configureLayers() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        buttonLayer.frame = bounds.largestContainedSquare.offsetBy(dx: 0, dy: 0)
        buttonLayer.addSublayer(outerCircle)
        buttonLayer.addSublayer(inProgressLayer)
        buttonLayer.addSublayer(innerCircle)
        
        layer.addSublayer(badgeLayer)
        layer.addSublayer(animatedBackground)
        layer.addSublayer(buttonLayer)
    }
}
