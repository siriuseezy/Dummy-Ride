//
//  SkEffector.swift
//  AirHockey
//
//  Created by Tomáš Macho on 24/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SpriteKit

protocol SKEffector {
    func blinking(_ node: SKNode,_ time: TimeInterval)
}

extension SKEffector where Self: SKScene {
    
    func blinking(_ node: SKNode,_ time: TimeInterval){
        
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: time)
        fadeOut.timingMode = .easeIn
        
        let fadeIn = SKAction.fadeIn(withDuration: time)
        fadeIn.timingMode = .easeOut
        
        node.run(SKAction.repeatForever(SKAction.sequence([fadeOut,fadeIn])))
        
        
    }
    
    func fadeIn(_ node: SKNode, _ time: TimeInterval){
        
        let fadein = SKAction.fadeIn(withDuration: time)
        node.run(fadein)
        
        
    }
    
    func fadeOut(_ node: SKNode,_ time: TimeInterval,_ die: Bool = true, _ easingOut: Bool = false){
        
       let fadeout = SKAction.fadeOut(withDuration: time)
        if easingOut {
            fadeout.timingMode = .easeOut
        }
        if !die {
       let die = SKAction.removeFromParent()
            node.run(SKAction.sequence([fadeout,die]))
        } else {
            node.run(fadeout)
        }
    }
    
    func bumpNode(node: SKNode, velkost: CGFloat, cas: TimeInterval, casSpat: TimeInterval){
        
        let bump = SKAction.scale(to: velkost, duration: cas)
        bump.timingMode = .easeOut
        
        let spat = SKAction.scale(to: 1, duration: casSpat)
        spat.timingMode = .easeOut
        
        node.run(SKAction.sequence([bump,spat]))
    }
    
}