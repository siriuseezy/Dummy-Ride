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
        
         //print("CONTACT: \(contact.nodeA.name) \(contact.nodeB.name)")
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
            
            if(!isPlaying){
                return
            }
            
            var velocity = abs(node.physicsBody!.velocity.x)
            velocity += abs(node.physicsBody!.velocity.y)
            velocity += abs(node.physicsBody!.velocity.z)
            
            if(velocity > 4){
                node.name = "targetBlack"
                let material = SCNMaterial()
                material.lightingModel = .blinn
                material.diffuse.contents = UIColor.darkGray
                node.geometry?.materials = [material]
                
                if node.parent!.name != "roadTemplate" {
                    if roadManager.livingNodes[node.parent!] != nil {
                        
                    
                   roadManager.livingNodes[node.parent!]![node] = true
                    
                    //roadManager.livingNodes[node.parent!]![node] = true
                    var children = roadManager.livingNodes[node.parent!]!
                    children[node] = true
                    
                    let count = children.count
                    var damaged = 0
                    for i in children {
                        if i.value == true {
                            damaged += 1
                        }
                    }
                    
                    let percentage: Float = Float(damaged)/Float(count)
                    
                    //ak aspon polovica je vyrachana prebehne wow efekt a prirata body!
                    if percentage > 0.39 {
                        //EFEKT TODO!!
                        skGame.showAwesome()
                        skGame.colorFlare(color: .white, alpha: 0.7, time: 0.3,moveUpside: false)
                        
                        for i in children {
                            children[i.key] = true
                            if i.key.name != "targetBlack" {
                                i.key.name = "targetBlack"
                                let material = SCNMaterial()
                                material.lightingModel = .blinn
                                material.diffuse.contents = UIColor.darkGray
                                i.key.geometry?.materials = [material]

                                let z = roadManager.cameraHolder.position.z - i.key.presentation.position.z
                                skGame.plusScore(x: i.key.presentation.position.x,y: i.key.presentation.position.y, z: z)

                                let particlesNode = roadManager.templates.rootNode.childNode(withName: "boom", recursively: true)!
                                
                                let klon = SCNNode()
                                klon.position = i.key.presentation.position
                                klon.isHidden = false
                                node.parent!.addChildNode(klon)
                                
                                let boom:SCNParticleSystem = (particlesNode.particleSystems?.first)!
                                let kopia = boom.copy() as! SCNParticleSystem
                                kopia.emitterShape = i.key.geometry!
                                klon.addParticleSystem(kopia)
                                i.key.physicsBody?.applyForce(SCNVector3(0,0,-23), asImpulse: true)
                            }
                        }
                        
                    }
                    roadManager.livingNodes[node.parent!] = children
                    }
                }
                
                let z = roadManager.cameraHolder.position.z - node.presentation.position.z
                skGame.plusScore(x: node.presentation.position.x,y: node.presentation.position.y, z: z)
            }
            return
        }
        
        
        if let node = detectNodeDeleting(contact){
          //  print("DELETING NODE: \(node.name)")
            node.physicsBody = nil
            node.removeFromParentNode()
            return
        }
        
        if let node = detectBonusCollected(contact){
            print("BONUS")
            
//            print(contact.nodeA.name)
//            print(contact.nodeB.name)
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

            let scaleDown = SCNAction.scale(to: 2.5, duration: 0.3)
            let fadeOut = SCNAction.fadeOut(duration: 0.35)
            scaleDown.timingMode = .easeOut
            let die = SCNAction.removeFromParentNode()
            clon.runAction(SCNAction.sequence([SCNAction.group([scaleDown,fadeOut]),die]))
            
            if node.name == "diamond" {
                clon.parent!.childNode(withName: "firework", recursively: true)!.isHidden = false
                scene.physicsWorld.removeAllBehaviors()
            }
            
            fireBonus(name: name!)
            return
        }
        
        if let reason = detectGameOver(contact){
            
            if(!isPlaying){
                return
            }
            
            if contact.nodeA.name!.starts(with: "target"){
         //   if contact.nodeA.name! == "target" {
                let move = SCNAction.move(by: SCNVector3(x:0,y:0,z:-25), duration: 1)
                move.timingMode = .easeOut
                contact.nodeA.presentation.runAction(move)
                let flickering = SCNAction.fadeOut(duration: 0.25)
                let flickeringB = SCNAction.fadeIn(duration: 0.25)
                contact.nodeA.runAction(SCNAction.repeat(SCNAction.sequence([flickering,flickeringB]), count: 2))
            } else if contact.nodeB.name!.starts(with: "target") {
            //    } else if contact.nodeB.name! == "target" {
                let move = SCNAction.move(by: SCNVector3(x:0,y:0,z:-25), duration: 1.5)
                move.timingMode = .easeIn
                contact.nodeB.runAction(move)
                let flickering = SCNAction.fadeOpacity(to: 0.2, duration: 0.25)
                let flickeringB = SCNAction.fadeIn(duration: 0.25)
                contact.nodeB.presentation.runAction(SCNAction.repeat(SCNAction.sequence([flickering,flickeringB]), count: 3))
            }

            print("GAME OVER")
            firstTouch = false
            //print(contact.nodeA.name)
            //print(contact.nodeB.name)
            let smrt = returnRightNode(contact, "SMRT")
            //smrt.isHidden = true
            smrt.physicsBody?.contactTestBitMask = 0
            smrt.physicsBody?.categoryBitMask = 0
            gameOver(reason: reason)
            return
        }
        
        if detectLevelCompleted(contact){
            
            if(!isPlaying){
                return
            }
            
            for i in figurine.childNodes {
                i.physicsBody!.velocity = SCNVector3(x: i.physicsBody!.velocity.x * 2, y: i.physicsBody!.velocity.y * 2, z: i.physicsBody!.velocity.z * 2)
            }
            
            
            ///prejdeny level
            print("LEVEL COMPLETED")
            firstTouch = false
            gameWin()
        }
    }
    
    
    func detectTargetHit(_ contact: SCNPhysicsContact) -> SCNNode? {
        
        
        //print("TARGETHIT: \(contact.nodeA.name) + \(contact.nodeB.name)")
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
            } else if contact.nodeA.name! == "diamond" {
                return contact.nodeA
            }
            
        }
        
        if contact.nodeB.name != nil {
            
            if contact.nodeB.name!.starts(with: "bonusCircle") {
                let number = contact.nodeB.name!.suffix(1)
                contact.nodeB.name = "b" + number
                return contact.nodeB
            } else if contact.nodeB.name! == "diamond" {
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
    
    func detectGameOver(_ contact: SCNPhysicsContact) -> Int? {
        
        
        //pozriet preco sa zrazila smrt so smrtou - lebo su kinematic a pri pohybe sa hybu aj ony
//        print("SMRT??")
//        print(contact.nodeA.name)
//        print(contact.nodeB.name)
        
        if contact.nodeA.name == "NILcameraSMRT" || contact.nodeB.name == "NILcameraSMRT" {
            return nil
        }
        
        if contact.nodeA.name == "SMRT" && contact.nodeB.name == "SMRT" {
            return nil
        }
        
        //skapanie
        if contact.nodeA.name == "SMRT" && contact.nodeB.parent?.name == "Figurine" {
            return 1
        } else if contact.nodeB.name == "SMRT" && contact.nodeA.parent?.name == "Figurine" {
            return 1
        } else if contact.nodeA.name == "cameraSMRT" && contact.nodeB.name?.starts(with: "target") == true {
//          } else if contact.nodeA.name == "cameraSMRT" && contact.nodeB.name == "target" {
            return 2
        } else if contact.nodeB.name == "cameraSMRT" && contact.nodeA.name?.starts(with: "target") == true {
//          } else if contact.nodeB.name == "cameraSMRT" && contact.nodeA.name == "target" {
 
            return 2
        } else {
            return nil
        }
        
    }

    
    
    
}
