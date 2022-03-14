//
//  UIView+NibExtension.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 12/03/22.
//

import UIKit

extension UIView {
    
    static func loadFromNib() -> UINib? {
        let bundle = Bundle(for: self.classForCoder())// IMP : Because @IBDesignables render on Storyboard with different bundle than the app-bundle itself
        if let identifier = NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last {
            return UINib(nibName: identifier, bundle: bundle)
        }
        
        return nil
    }
    
    static func reusableIndentifer() -> String {
        return String(describing: self)
    }
}
