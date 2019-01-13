//
//  Randomizator.swift
//  AirHockey
//
//  Created by Tomáš Macho on 19/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit

protocol Randomizator {
    
    func percentualnaSanca(percento: Int) -> Bool
    func random50na50() -> Bool
    func randomCislo(rozsah: UInt32) -> Int
    func randomRozmer(rozsah: UInt32) -> CGFloat
    func randomFarbaTarget(colorPalette: Int) -> UIColor
}

struct backgroundColors {

    var color1: UIColor!
    var color2: UIColor!
}

extension Randomizator {
    
    func percentualnaSanca(percento: Int) -> Bool {
        
        let sto = arc4random() % 100
        if percento-1 >= sto {
            return true
        } else {
            return false
        }
        
    }
    
    func random50na50() -> Bool {
        if arc4random() % 2 == 0 {
            return true
        } else {
            return false
        }
    }
    
    func randomCislo(rozsah: UInt32)-> Int{
        return Int(arc4random() % rozsah)
    }
    
    func randomRozmer(rozsah: UInt32) -> CGFloat {
        return CGFloat(arc4random() % (rozsah * 10) + 1) / 10
    }
    
    func randomFarbaTarget(colorPalette: Int) -> UIColor {
        
        switch colorPalette {
            
        case 0:
            
            let farba = randomCislo(rozsah: 5)
            switch farba {
            case 0: return UIColor(red: 225/255.0, green: 112/255.0, blue: 202/255.0, alpha: 1)
            case 1: return UIColor(red: 115/255.0, green: 204/255.0, blue: 252/255.0, alpha: 1)
            case 2: return UIColor(red: 144/255.0, green: 255/255.0, blue: 165/255.0, alpha: 1)
            case 3: return UIColor(red: 165/255.0, green: 103/255.0, blue: 251/255.0, alpha: 1)
            case 4: return UIColor(red: 254/255.0, green: 251/255.0, blue: 155/255.0, alpha: 1)
            default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1 )
            }
            
        case 1:
            
            let farba = randomCislo(rozsah: 5)
            switch farba {
            case 0: return UIColor(red: 219/255.0, green: 0/255.0, blue: 188/255.0, alpha: 1)
            case 1: return UIColor(red: 128/255.0, green: 0/255.0, blue: 250/255.0, alpha: 1)
            case 2: return UIColor(red: 64/255.0, green: 0/255.0, blue: 250/255.0, alpha: 1)
            case 3: return UIColor(red: 103/255.0, green: 183/255.0, blue: 253/255.0, alpha: 1)
            case 4: return UIColor(red: 144/255.0, green: 255/255.0, blue: 249/255.0, alpha: 1)
            default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1 )
            }
            
        case 2:
            
            let farba = randomCislo(rozsah: 5)
            switch farba {
            case 0: return UIColor(red: 225/255.0, green: 106/255.0, blue: 209/255.0, alpha: 1)
            case 1: return UIColor(red: 179/255.0, green: 115/255.0, blue: 228/255.0, alpha: 1)
            case 2: return UIColor(red: 163/255.0, green: 139/255.0, blue: 251/255.0, alpha: 1)
            case 3: return UIColor(red: 138/255.0, green: 148/255.0, blue: 229/255.0, alpha: 1)
            case 4: return UIColor(red: 166/255.0, green: 207/255.0, blue: 253/255.0, alpha: 1)
            default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1 )
            }
            
        case 3:
            
            let farba = randomCislo(rozsah: 5)
            switch farba {
            case 0: return UIColor(red: 226/255.0, green: 127/255.0, blue: 250/255.0, alpha: 1)
            case 1: return UIColor(red: 115/255.0, green: 204/255.0, blue: 252/255.0, alpha: 1)
            case 2: return UIColor(red: 255/255.0, green: 191/255.0, blue: 170/255.0, alpha: 1)
            case 3: return UIColor(red: 254/255.0, green: 254/255.0, blue: 113/255.0, alpha: 1)
            case 4: return UIColor(red: 254/255.0, green: 254/255.0, blue: 198/255.0, alpha: 1)
            default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1 )
            }
            
        case 4:
            
            let farba = randomCislo(rozsah: 5)
            switch farba {
            case 0: return UIColor(red: 243/255.0, green: 210/255.0, blue: 57/255.0, alpha: 1)
            case 1: return UIColor(red: 230/255.0, green: 143/255.0, blue: 47/255.0, alpha: 1)
            case 2: return UIColor(red: 220/255.0, green: 46/255.0, blue: 115/255.0, alpha: 1)
            case 3: return UIColor(red: 207/255.0, green: 39/255.0, blue: 249/255.0, alpha: 1)
            case 4: return UIColor(red: 121/255.0, green: 35/255.0, blue: 250/255.0, alpha: 1)
            default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1 )
            }
            
        case 5:
            
            let farba = randomCislo(rozsah: 5)
            switch farba {
            case 0: return UIColor(red: 203/255.0, green: 252/255.0, blue: 254/255.0, alpha: 1)
            case 1: return UIColor(red: 229/255.0, green: 255/255.0, blue: 251/255.0, alpha: 1)
            case 2: return UIColor(red: 245/255.0, green: 219/255.0, blue: 243/255.0, alpha: 1)
            case 3: return UIColor(red: 210/255.0, green: 190/255.0, blue: 221/255.0, alpha: 1)
            case 4: return UIColor(red: 190/255.0, green: 187/255.0, blue: 219/255.0, alpha: 1)
            default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1 )
            }
            
        default: return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            
            
        }
        
    }
    
    func randomFarbyPozadie() -> backgroundColors {
        
        let cislo = randomCislo(rozsah: 11)
        switch cislo {
        case 0: return backgroundColors(color1: UIColor(red: 33/255, green: 25/255, blue: 70/255, alpha: 1), color2: UIColor(red: 199/255, green: 4/255, blue: 219/255, alpha: 1))
        
        case 1: return backgroundColors(color1: UIColor(red: 61/255, green: 117/255, blue: 182/255, alpha: 1), color2: UIColor(red: 253/255, green: 127/255, blue: 199/255, alpha: 1))
        case 2: return backgroundColors(color1: UIColor(red: 213/255, green: 19/255, blue: 162/255, alpha: 1), color2: UIColor(red: 120/255, green: 23/255, blue: 212/255, alpha: 1))
        case 3: return backgroundColors(color1: UIColor(red: 23/255, green: 16/255, blue: 59/255, alpha: 1), color2: UIColor(red: 115/255, green: 36/255, blue: 220/255, alpha: 1))
        case 4: return backgroundColors(color1: UIColor(red: 46/255, green: 34/255, blue: 95/255, alpha: 1), color2: UIColor(red: 194/255, green: 101/255, blue: 162/255, alpha: 1))
        case 5: return backgroundColors(color1: UIColor(red: 41/255, green: 254/255, blue: 155/255, alpha: 1), color2: UIColor(red: 184/255, green: 84/255, blue: 224/255, alpha: 1))
        case 6: return backgroundColors(color1: UIColor(red: 244/255, green: 186/255, blue: 80/255, alpha: 1), color2: UIColor(red: 235/255, green: 55/255, blue: 137/255, alpha: 1))
        case 7: return backgroundColors(color1: UIColor(red: 16/255, green: 30/255, blue: 53/255, alpha: 1), color2: UIColor(red: 18/255, green: 152/255, blue: 225/255, alpha: 1))
        case 8: return backgroundColors(color1: UIColor(red:223/255, green: 88/255, blue: 56/255, alpha: 1), color2: UIColor(red: 239/255, green: 194/255, blue: 45/255, alpha: 1))
        case 9: return backgroundColors(color1: UIColor(red: 123/255, green: 15/255, blue: 63/255, alpha: 1), color2: UIColor(red: 239/255, green: 194/255, blue: 45/255, alpha: 1))
        case 10: return backgroundColors(color1: UIColor(red: 4/255, green: 10/255, blue: 79/255, alpha: 1), color2: UIColor(red: 170/255, green: 0/255, blue: 59/255, alpha: 1))
            

            
        default: return backgroundColors(color1: UIColor.white, color2: UIColor.black)
        }
        
    }
}
