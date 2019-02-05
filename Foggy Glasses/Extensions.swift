//
//  Extensions.swift
//  Slide Into The DMs
//
//  Created by Ryan Temple on 7/10/18.
//  Copyright © 2018 Ryan Temple. All rights reserved.
//

import UIKit

extension UIView {
    func templeShadow() {
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func largeTempleShadow() {
        layer.shadowRadius = 8
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func noShadow() {
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOpacity = 0
        
    }
    
    func fadeIn(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) { _ in
            completion()
        }
    }
    
    func fadeOut(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            completion()
        }
    }
}


extension Collection {
    
    /**
     * Returns a random element of the Array or nil if the Array is empty.
     */
    var sample : Element? {
        guard !isEmpty else { return nil }
        let offset = arc4random_uniform(numericCast(self.count))
        let idx = self.index(self.startIndex, offsetBy: numericCast(offset))
        return self[idx]
    }
    
    /**
     * Returns `count` random elements from the array.
     * If there are not enough elements in the Array, a smaller Array is returned.
     * Elements will not be returned twice except when there are duplicate elements in the original Array.
     */
    func sample(_ count : UInt) -> [Element] {
        let sampleCount = Swift.min(numericCast(count), self.count)
        
        var elements = Array(self)
        var samples : [Element] = []
        
        while samples.count < sampleCount {
            let idx = (0..<elements.count).sample!
            samples.append(elements.remove(at: idx))
        }
        
        return samples
    }
    
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        return Array(Set<Iterator.Element>(self))
    }
    
    func uniqueOrdered() -> [Iterator.Element] {
        return reduce([Iterator.Element]()) { $0.contains($1) ? $0 : $0 + [$1] }
    }
}

extension UIColor {
    static let slideBlue = UIColor(red:0.67, green:0.88, blue:0.96, alpha:1.0)
    static let keyTextColor = UIColor.black//UIColor(red:0.29, green:0.69, blue:0.85, alpha:1.0)
    static let darkSlideBlue = UIColor(red:0.00, green:0.58, blue:1.00, alpha:1.0)
    static let offWhite = UIColor.init(white: 0.985, alpha: 1)
}


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension Array {
    
    /**
     * Shuffles the elements in the Array in-place using the
     * [Fisher-Yates shuffle](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle).
     */
    mutating func shuffle() {
        guard self.count >= 1 else { return }
        
        for i in (1..<self.count).reversed() {
            let j = (0...i).sample!
            self.swapAt(j, i)
        }
    }
    
    /**
     * Returns a new Array with the elements in random order.
     */
    var shuffled : [Element] {
        var elements = self
        elements.shuffle()
        return elements
    }
    
}

//Mark: Style Extensions
extension UIView {
    func setBordersSettings() {
        let c1GreenColor = UIColor.lightGray
        self.layer.borderWidth = 1.0
        self.layer.borderColor = c1GreenColor.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor;
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.2
    }
    
    var dropShadow: Bool {
        set{
            if newValue {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.4
                layer.shadowRadius = 1
                layer.shadowOffset = CGSize(width: 2, height: 4)
            } else {
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowOpacity = 0
                layer.shadowRadius = 0
                layer.shadowOffset = CGSize.zero
            }
        }
        get {
            return layer.shadowOpacity > 0
        }
    }
}

//Mark: Layout Extensions
extension UIView {
    func centerHoriziontally(in view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerVertically(in view: UIView) {
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func center(in view: UIView) {
        centerHoriziontally(in: view)
        centerVertically(in: view)
    }
    
    func pin(in view: UIView) {
        anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func withSize(width: CGFloat, height: CGFloat) {
        anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: width, height: width)
    }
    
    func slideUp(completion: @escaping() -> ()) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }, completion: { (jeff) in
            completion()
        })
    }
    
    @objc func slideDown(completion: @escaping() -> ()) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.frame = CGRect(x: 0, y: self.frame.size.height, width: (self.frame.size.width), height: (self.frame.size.height))
        }) { (nb) in
            self.removeFromSuperview()
            completion()
        }
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}


extension UIView {
    
    func startRotating(duration: CFTimeInterval = 3, repeatCount: Float = Float.infinity, clockwise: Bool = true) {
        
        if self.layer.animation(forKey: "transform.rotation.z") != nil {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let direction = clockwise ? 1.0 : -1.0
        animation.toValue = NSNumber(value: .pi * 2 * direction)
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey:"transform.rotation.z")
    }
    
    func stopRotating() {
        
        self.layer.removeAnimation(forKey: "transform.rotation.z")
        
    }
    
    enum AnimationKeyPath: String {
        case opacity = "opacity"
    }
    
    func flash(animation: AnimationKeyPath ,withDuration duration: TimeInterval = 1, repeatCount: Float = 5){
        let flash = CABasicAnimation(keyPath: AnimationKeyPath.opacity.rawValue)
        flash.duration = duration
        flash.fromValue = 1 // alpha
        flash.toValue = 0.2 // alpha
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = repeatCount
        
        layer.add(flash, forKey: nil)
    }
    
}

extension Int {
    func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}

extension BinaryInteger {
    
    static func rand(_ min: Self, _ max: Self) -> Self {
        let _min = min
        let difference = max+1 - _min
        return Self(arc4random_uniform(UInt32(difference))) + _min
    }
}

extension BinaryFloatingPoint {
    
    private func toInt() -> Int {
        // https://stackoverflow.com/q/49325962/4488252
        if let value = self as? CGFloat {
            return Int(value)
        }
        return Int(self)
    }
    
    static func rand(_ min: Self, _ max: Self, precision: Int) -> Self {
        
        if precision == 0 {
            let min = min.rounded(.down).toInt()
            let max = max.rounded(.down).toInt()
            return Self(Int.rand(min, max))
        }
        
        let delta = max - min
        let maxFloatPart = Self(pow(10.0, Double(precision)))
        let maxIntegerPart = (delta * maxFloatPart).rounded(.down).toInt()
        let randomValue = Int.rand(0, maxIntegerPart)
        let result = min + Self(randomValue)/maxFloatPart
        return Self((result*maxFloatPart).toInt())/maxFloatPart
    }
}
extension UIDevice {
    
    static var hasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        
        return false
    }
    
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }
        
        return modelIdentifier == "iPhone10,3" || modelIdentifier == "iPhone10,6"
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

extension String {
    
    func strip(set: Set<Character>) -> String {
        return self.filter { set.contains($0) }
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
}

protocol Showable where Self: UIView {}

extension Showable {
    
    func show(_ view: UIView? = nil) {
        
        if let view = view {
            self.animate(view)
        } else {
            self.animate(self)
        }
    }
    
    private func animate(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: [.allowUserInteraction],
                       animations: {
                        view.transform = CGAffineTransform.identity
        })
    }
}
