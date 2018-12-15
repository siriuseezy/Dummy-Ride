//
//  UIImage.swift
//  Skeleton Ride
//
//  Created by Tomáš Macho on 11/12/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func image(from layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size,
                                               layer.isOpaque, UIScreen.main.scale)
        
        defer { UIGraphicsEndImageContext() }
        
        // Don't proceed unless we have context
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
