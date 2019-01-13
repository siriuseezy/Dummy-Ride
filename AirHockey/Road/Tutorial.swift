//
//  Tutorial.swift
//  Skeleton Ride
//
//  Created by Tomáš Macho on 19/12/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit

extension Road {
    
    
    func tutorialRandomLength() -> CGFloat {
        
        let level = user.retrieveActualLevel()
        
        switch level {
        case 1...5: return CGFloat(20 * Constants.blockLength)
        case 6...9: return CGFloat(randomCislo(rozsah: 5) * Int(Constants.blockLength)) + CGFloat(20 * Constants.blockLength)
        case 10...15: return CGFloat(randomCislo(rozsah: 10) * Int(Constants.blockLength)) + CGFloat(20 * Constants.blockLength)
        case 16...25: return CGFloat(randomCislo(rozsah: 20) * Int(Constants.blockLength)) + CGFloat(20 * Constants.blockLength)
        default: return 0
        }
        
    }

    
    
    
    
    
    
}
