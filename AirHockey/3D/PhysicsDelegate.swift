//
//  PhysicsDelegate.swift
//  AirHockey
//
//  Created by Tomáš Macho on 13/06/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit


extension GameViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
//        print("CONTACT")
//        print(contact.nodeA.name)
//        print(contact.nodeB.name)
        
        if(contact.nodeA.parent?.name == "Figurine" && contact.nodeB.parent?.name == "Figurine"){
            return
        }
        if(contact.nodeA.parent?.name == "Figurine" && contact.nodeB.parent?.name == "base"){
            return
        }

        //CAT_COL_CONT
        //figurine 1 1 11
        //targets 1 1 4
        //bonus 1 1 5
        
        //end - 8 0 8
        //camera SMRT - 4 0 4
        //road SMRT - 2 0 2
        //node SMRT - 4 0 4
        
        if let node = detectTargetHit(contact){
            print("IMPULSE")
            var velocity = abs(node.physicsBody!.velocity.x)
            velocity += abs(node.physicsBody!.velocity.y)
            velocity += abs(node.physicsBody!.velocity.z)
            
            if(velocity > 4){
                node.name = "targetBlack"
                let material = SCNMaterial()
                material.lightingModel = .blinn
                material.diffuse.contents = UIColor.darkGray
                node.geometry?.materials = [material]
                
                let cameraZ = roadManager.cameraHolder.position.z
                let z = roadManager.cameraHolder.position.z - node.presentation.position.z
                
                skGame.plusScore(x: node.presentation.position.x,y: node.presentation.position.y, z: z)
            }
            return
        }
        
        
        if let node = detectNodeDeleting(contact){
            print("DELETING NODE")
            node.physicsBody = nil
            node.removeFromParentNode()
            return
        }
        
        if let node = detectBonusCollected(contact){
            print("BONUS")
            print(contact.nodeA.name)
            print(contact.nodeB.name)
            //neviem preco ale pri padnuti figurny nabok alebo pri restarte obcas nastane kolizia smrt a bonus asi je nejaky bonus pri kamere hoci by nemal byt
            if contact.nodeA.name == "SMRT" || contact.nodeB.name == "SMRT" {
             return
            }
            
            let name = node.name
            let clon = node.clone()
            node.removeFromParentNode()
            clon.physicsBody = nil
            if clon.childNode(withName: "particle", recursively: true) != nil {
            clon.childNode(withName: "particle", recursively: true)!.isHidden = false
            }
            roadManager.rootNode.addChildNode(clon)

            let scaleDown = SCNAction.scale(to: 0, duration: 0.3)
            scaleDown.timingMode = .easeOut
            let die = SCNAction.removeFromParentNode()
            clon.runAction(SCNAction.sequence([scaleDown,die]))
            fireBonus(name: name!)
            return
        }
        
        if detectGameOver(contact){
            
            if(!isPlaying){
                return
            }
            
            
            for i in figurine.childNodes {
                print("HLAVA: \(i.physicsBody!.velocityFactor)")
            }
            
            print("GAME OVER")
            firstTouch = false
            print(contact.nodeA.name)
            print(contact.nodeB.name)
            let smrt = returnRightNode(contact, "SMRT")
            smrt.isHidden = true
            smrt.physicsBody?.contactTestBitMask = 0
            smrt.physicsBody?.categoryBitMask = 0
            gameOver()
            return
        }
        
        if detectLevelCompleted(contact){
            
            if(!isPlaying){
                return
            }
            ///prejdeny level
            print("LEVEL COMPLETED")
            firstTouch = false
            scene.physicsWorld.removeAllBehaviors()
            gameWin()
        }

        //dokodit predmety na zbieranie
        
    }
    
    
    func detectTargetHit(_ contact: SCNPhysicsContact) -> SCNNode? {
        
        if(contact.nodeA.parent?.name == "Figurine" && contact.nodeB.name == "target"){
            return contact.nodeB
        } else if(contact.nodeB.parent?.name == "Figurine" && contact.nodeA.name == "target"){
            return contact.nodeA
        } else if (contact.nodeA.name == "bonusBall" && contact.nodeB.name == "target"){
            return contact.nodeB
        } else if (contact.nodeB.name == "bonusBall" && contact.nodeA.name == "target"){
            return contact.nodeA
        } else {
            return nil
        }

    }
    
    func detectBonusCollected(_ contact: SCNPhysicsContact) -> SCNNode? {
        if contact.nodeA.name != nil {
          
            if contact.nodeA.name!.starts(with: "bonusCircle") {
                let number = contact.nodeA.name!.suffix(1)
                contact.nodeA.name = "b" + number
                return contact.nodeA
            }
            
        }
        
        if contact.nodeB.name != nil {
            
            if contact.nodeB.name!.starts(with: "bonusCircle") {
                let number = contact.nodeB.name!.suffix(1)
                contact.nodeB.name = "b" + number
                return contact.nodeB
            }
            
        }
        
        return nil

    }
    
    func detectNodeDeleting(_ contact: SCNPhysicsContact) -> SCNNode? {
        
        if contact.nodeA.name == "nodeSMRT" {
            return contact.nodeB
        } else if contact.nodeB.name == "nodeSMRT" {
            return contact.nodeA
        } else {
            return nil
        }
        
        
        
    }
    
    func detectLevelCompleted(_ contact: SCNPhysicsContact) -> Bool{
        
        if contact.nodeA.name == "end" {
            
            if contact.nodeB.parent?.name == "Figurine" {
                
                return true
                
            } else {
                
                return false
                
            }
            
        } else if contact.nodeB.name == "end"{
            
            if contact.nodeB.parent?.name == "Figurine" {
                
                return true
                
            } else {
                
                return false
                
            }
            
        } else {
            
            return false
        }
        
        
    }

    
    func returnRightNode(_ contact: SCNPhysicsContact,_ name: String) -> SCNNode {
        
        if contact.nodeA.name == name {
            return contact.nodeA
        } else {
            return contact.nodeB
        }
        
        
    }
    
    func detectGameOver(_ contact: SCNPhysicsContact) -> Bool{
        
        
        //pozriet preco sa zrazila smrt so smrtou - lebo su kinematic a pri pohybe sa hybu aj ony
//        print("SMRT??")
//        print(contact.nodeA.name)
//        print(contact.nodeB.name)
        
        if contact.nodeA.name == "NILcameraSMRT" || contact.nodeB.name == "NILcameraSMRT" {
            return false
        }
        
        if contact.nodeA.name == "SMRT" && contact.nodeB.name == "SMRT" {
            return false
        }
        
        //skapanie
        if contact.nodeA.name == "SMRT" && contact.nodeB.parent?.name == "Figurine" {
            return true
        } else if contact.nodeB.name == "SMRT" && contact.nodeA.parent?.name == "Figurine" {
            return true
        } else if contact.nodeA.name == "cameraSMRT" && contact.nodeB.name?.starts(with: "target") == true {
            
            return true
        } else if contact.nodeB.name == "cameraSMRT" && contact.nodeA.name?.starts(with: "target") == true {
            
            return true
        } else {
            return false
        }
        
    }

    
    
    
}
