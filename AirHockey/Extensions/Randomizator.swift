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
    func randomFarbaTarget() -> UIColor
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
    
    func randomFarbaTarget() -> UIColor {
        
        let cislo = randomCislo(rozsah: 7)
        
        if cislo == 0 {
            return UIColor(red: 0/255, green: 234/255, blue: 255/255, alpha: 1)
        } else if cislo == 1 {
            return UIColor(red: 120/255, green: 103/255, blue: 255/255, alpha: 1)
        } else if cislo == 2 {
            return UIColor(red: 255/255, green: 118/255, blue: 245/255, alpha: 1)
        } else if cislo == 3 {
            return UIColor(red: 255/255, green: 68/255, blue: 139/255, alpha: 1)
        } else if cislo == 4 {
            return UIColor(red: 255/255, green: 174/255, blue: 81/255, alpha: 1)
        } else if cislo == 5 {
            return UIColor(red: 255/255, green: 49/255, blue: 72/255, alpha: 1)
        } else {
            return UIColor(red: 109/255, green: 255/255, blue: 162/255, alpha: 1)
        }
        
    }
    
    func randomFarbyPozadie() -> backgroundColors {
        
        let cislo = randomCislo(rozsah: 8)
        switch cislo {
        case 0: return backgroundColors(color1: UIColor(red: 33/255, green: 25/255, blue: 70/255, alpha: 1), color2: UIColor(red: 199/255, green: 4/255, blue: 219/255, alpha: 1))
        case 1: return backgroundColors(color1: UIColor(red: 61/255, green: 117/255, blue: 182/255, alpha: 1), color2: UIColor(red: 253/255, green: 127/255, blue: 199/255, alpha: 1))
        case 2: return backgroundColors(color1: UIColor(red: 213/255, green: 19/255, blue: 162/255, alpha: 1), color2: UIColor(red: 120/255, green: 23/255, blue: 212/255, alpha: 1))
        case 3: return backgroundColors(color1: UIColor(red: 23/255, green: 16/255, blue: 59/255, alpha: 1), color2: UIColor(red: 115/255, green: 36/255, blue: 220/255, alpha: 1))
        case 4: return backgroundColors(color1: UIColor(red: 46/255, green: 34/255, blue: 95/255, alpha: 1), color2: UIColor(red: 194/255, green: 101/255, blue: 162/255, alpha: 1))
        case 5: return backgroundColors(color1: UIColor(red: 41/255, green: 254/255, blue: 155/255, alpha: 1), color2: UIColor(red: 184/255, green: 84/255, blue: 224/255, alpha: 1))
        case 6: return backgroundColors(color1: UIColor(red: 244/255, green: 186/255, blue: 80/255, alpha: 1), color2: UIColor(red: 235/255, green: 55/255, blue: 137/255, alpha: 1))
        case 7: return backgroundColors(color1: UIColor(red: 16/255, green: 30/255, blue: 53/255, alpha: 1), color2: UIColor(red: 18/255, green: 152/255, blue: 225/255, alpha: 1))
        default: return backgroundColors(color1: UIColor.white, color2: UIColor.black)
        }
        
    }
}
