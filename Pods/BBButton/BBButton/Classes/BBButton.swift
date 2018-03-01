//
//  BBButton.swift
//  BBButton
//
//  Created by Blake Barrett on 2/28/18.
//

import Foundation
import UIKit

public typealias Closure = (Any?) -> Void

/**
 * Add a closure click listener.
 *
 */
public protocol BBButton {
    
    func onClick(_ value: Closure?)
    
}

extension UIControl: BBButton {
    
    fileprivate static var controlWasClickedEvent = "controlWasClicked"
    fileprivate static var controlWasClickedNotificationName = NSNotification.Name(rawValue: UIControl.controlWasClickedEvent)
    
    public func onClick(_ value: Closure?) {
        let onControlClicked = #selector(self.onControlClicked)
        addTarget(self,
                  action: onControlClicked,
                  for: .touchUpInside)
        
        NotificationCenter.default.addObserver(forName: UIButton.controlWasClickedNotificationName,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
                                                value?(self)
        }
    }
    
    @objc fileprivate func onControlClicked() {
        NotificationCenter.default.post(name: UIControl.controlWasClickedNotificationName, object: self)
    }
}
