//
//  Extensions.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/31/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

extension Date {
    func performDateFormattingToString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateInString = dateFormatter.string(from: self)
        return dateInString
    }
}

extension DateInterval {
    func formatToString() -> String? {
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = "yyyy-MM-dd"
        let dateIntervalInString = formatter.string(from: self)
        return dateIntervalInString
    }
}

extension UIViewController {
    func hideKeyboardOnTouchUpInside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UITextField {
    var isEmpty: Bool {
        if let text = self.text, text.isEmpty {
            return true
        } else {
            return false
        }
    }
}

extension Array where Element: Dateable {
    func groupedBy(dateComponent: Calendar.Component) -> [DateInterval: [Element]] {
        let initial: [DateInterval: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { accumulator, current in
            guard let currentDate = current.date else {
                return
            }
            
            let calendar = Calendar.autoupdatingCurrent
            
            guard let dateInterval = calendar.dateInterval(of: dateComponent, for: currentDate) else {
                return
            }
            let existing = accumulator[dateInterval] ?? []
            accumulator[dateInterval] = existing + [current]
        }
        
        return groupedByDateComponents
    }
}

extension UIActivityIndicatorView {
    func madeAdaptable() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.style = .white
            self.color = .black
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            self.style = .whiteLarge
            self.color = .black
        }
    }
}
