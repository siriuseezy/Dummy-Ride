//
//  SCNActions.swift
//  AirHockey
//
//  Created by Tomáš Macho on 13/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit

protocol ScnEffector {
    
}
extension ScnEffector {
    
    func moveBy(_ node: SCNNode, _ time: TimeInterval, _ distance: SCNVector3, _ timing: SCNActionTimingMode = .easeOut, _ key: String = ""){
        
    let move = SCNAction.move(by: distance, duration: time)
        move.timingMode = timing
        node.runAction(move, forKey: key)
        
    }
    
    func moveTo(_ node: SCNNode, _ time: TimeInterval, _ position: SCNVector3, _ timing: SCNActionTimingMode = .easeOut, _ key: String = ""){
        
        let move = SCNAction.move(to: position, duration: time)
        move.timingMode = timing
        node.runAction(move, forKey: key)
        
    }
    
    func fadeTo(_ node: SCNNode, _ time: TimeInterval, _ alpha: CGFloat, _ die: Bool = true, _ timing: SCNActionTimingMode = .easeOut, _ key: String = ""){
        
        let fade = SCNAction.fadeOpacity(to: alpha, duration: time)
        fade.timingMode = timing

        if die {
           let remove = SCNAction.removeFromParentNode()
           node.runAction(SCNAction.sequence([fade,remove]), forKey: key)
        } else {
            node.runAction(fade, forKey: key)
        }
    }
    
    func wait(_ node: SCNNode, _ time: TimeInterval, _ key: String = ""){
        
        let wait = SCNAction.wait(duration: time)
        node.runAction(wait, forKey: key)
        
    }
    
    func scaleDown(_ node: SCNNode, _ time: TimeInterval){
        
        let scaleDown = SCNAction.scale(to: 0, duration: time)
        let die = SCNAction.removeFromParentNode()
        node.runAction(SCNAction.sequence([scaleDown,die]))
        
    }
    
    func waitFadeOutDie(_ node: SCNNode, _ time1: TimeInterval, _ time2: TimeInterval, _ key: String = ""){
        
        let wait = SCNAction.wait(duration: time1)
        let fadeOut = SCNAction.fadeOut(duration: time2)
        let die = SCNAction.removeFromParentNode()
        let action = SCNAction.sequence([wait,fadeOut,die])
        if key != "" {
            node.runAction(action, forKey: key)
        } else {
            node.runAction(action)
        }
        
    }
    
    func blinking(_ node: SCNNode, _ time: TimeInterval, key: String = ""){
        
        let fadeOut = SCNAction.fadeOut(duration: time)
        fadeOut.timingMode = .easeOut
        let fadeIn = SCNAction.fadeIn(duration: time)
        fadeIn.timingMode = .easeOut
        node.runAction(SCNAction.repeatForever(SCNAction.sequence([fadeOut,fadeIn])))

    }
    
    
}
