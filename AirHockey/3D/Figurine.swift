//
//  Figurine.swift
//  AirHockey
//
//  Created by Tomáš Macho on 24/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit

extension GameViewController: dotyk {
    
    func createBody(){
        //setup figuriny
        if figurine != nil {
            figurine!.removeFromParentNode()
        }
        
        figurine = source.rootNode.childNode(withName: "Figurine", recursively: true)!.clone()
        head = figurine.childNode(withName: "head", recursively: true)!
        chestTop = figurine.childNode(withName: "chestTop", recursively: true)! //height: 2.6, ruky pripinam nie uplne hore
        chestBottom = figurine.childNode(withName: "chestBottom", recursively: true)! //height: 1.4
        
        leftArmTop = figurine.childNode(withName: "leftArmTop", recursively: true)!
        leftArmBottom = figurine.childNode(withName: "leftArmBottom", recursively: true)!
        rightArmTop = figurine.childNode(withName: "rightArmTop", recursively: true)!
        rightArmBottom = figurine.childNode(withName: "rightArmBottom", recursively: true)!
        leftHand = figurine.childNode(withName: "leftHand", recursively: true)!
        rightHand = figurine.childNode(withName: "rightHand", recursively: true)!
        
        leftLegTop = figurine.childNode(withName: "leftLegTop", recursively: true)!
        rightLegTop = figurine.childNode(withName: "rightLegTop", recursively: true)!
        leftLegBottom = figurine.childNode(withName: "leftLegBottom", recursively: true)!
        rightLegBottom = figurine.childNode(withName: "rightLegBottom", recursively: true)!
        leftFoot = figurine.childNode(withName: "leftFoot", recursively: true)!
        rightFoot = figurine.childNode(withName: "rightFoot", recursively: true)!
        
        let joint = SCNPhysicsBallSocketJoint(bodyA: head.physicsBody!, anchorA: SCNVector3(0,-1.4,0), bodyB: chestTop.physicsBody!, anchorB: SCNVector3(0,1.5,0))
    
        let chestJoin = SCNPhysicsBallSocketJoint(bodyA: chestTop.physicsBody!, anchorA: SCNVector3(0,-1.5,0), bodyB: chestBottom.physicsBody!, anchorB: SCNVector3(0,0.9,0))
        
        let leftJoin = SCNPhysicsBallSocketJoint(bodyA: chestTop.physicsBody!, anchorA: SCNVector3(0.7,1.25,0), bodyB: rightArmTop.physicsBody!, anchorB: SCNVector3(-0.1,1.45,0))
        let leftJoin2 = SCNPhysicsBallSocketJoint(bodyA: rightArmTop.physicsBody!, anchorA: SCNVector3(0,-1.5,0), bodyB: rightArmBottom.physicsBody!, anchorB: SCNVector3(0,1.5,0))
        
        let rightJoin = SCNPhysicsBallSocketJoint(bodyA: chestTop.physicsBody!, anchorA: SCNVector3(-0.7,1.25,0), bodyB: leftArmTop.physicsBody!, anchorB: SCNVector3(0.1,1.45,0))
        let rightJoin2 = SCNPhysicsBallSocketJoint(bodyA: leftArmTop.physicsBody!, anchorA: SCNVector3(0,-1.5,0), bodyB: leftArmBottom.physicsBody!, anchorB: SCNVector3(0,1.5,0))

        
        let leftLegJoin = SCNPhysicsBallSocketJoint(bodyA: chestBottom.physicsBody!, anchorA: SCNVector3(-0.45,-0.9,0), bodyB: leftLegTop.physicsBody!, anchorB: SCNVector3(0.1, 1.4,0))
        let leftLegJoin2 = SCNPhysicsBallSocketJoint(bodyA: leftLegTop.physicsBody!, anchorA: SCNVector3(0,-1.4,0), bodyB: leftLegBottom.physicsBody!, anchorB: SCNVector3(0, 1.4,0))
        
        
        let rightLegJoin = SCNPhysicsBallSocketJoint(bodyA: chestBottom.physicsBody!, anchorA: SCNVector3(0.45,-0.9,0), bodyB: rightLegTop.physicsBody!, anchorB: SCNVector3(-0.1, 1.4,0))
        let rightLegJoin2 = SCNPhysicsBallSocketJoint(bodyA: rightLegTop.physicsBody!, anchorA: SCNVector3(0,-1.4,0), bodyB: rightLegBottom.physicsBody!, anchorB: SCNVector3(0, 1.4,0))
        
        let leftFootJoin = SCNPhysicsBallSocketJoint(bodyA: leftLegBottom.physicsBody!, anchorA: SCNVector3(0,-1.25,0), bodyB: leftFoot.physicsBody!, anchorB: SCNVector3(0, 0.3,-0.5))
        let rightFootJoin = SCNPhysicsBallSocketJoint(bodyA: rightLegBottom.physicsBody!, anchorA: SCNVector3(0,-1.25,0), bodyB: rightFoot.physicsBody!, anchorB: SCNVector3(0, 0.3,-0.5))
        
        let rightHandJoin = SCNPhysicsBallSocketJoint(bodyA: rightArmBottom.physicsBody!, anchorA: SCNVector3(0,-0.85,0), bodyB: rightHand.physicsBody!, anchorB: SCNVector3(0, 0.58,0))
        
        let leftHandJoin = SCNPhysicsBallSocketJoint(bodyA: leftArmBottom.physicsBody!, anchorA: SCNVector3(0,-0.85,0), bodyB: leftHand.physicsBody!, anchorB: SCNVector3(0, 0.58,0))

        
        removableBehaviours = []
        removableBehDict = [:]
        
        scene.physicsWorld.removeAllBehaviors()
        scene.physicsWorld.addBehavior(joint)
        scene.physicsWorld.addBehavior(chestJoin)
        scene.physicsWorld.addBehavior(leftJoin)
        scene.physicsWorld.addBehavior(leftJoin2)
        scene.physicsWorld.addBehavior(rightJoin)
        scene.physicsWorld.addBehavior(rightJoin2)
        scene.physicsWorld.addBehavior(leftLegJoin)
        scene.physicsWorld.addBehavior(leftLegJoin2)
        scene.physicsWorld.addBehavior(rightLegJoin)
        scene.physicsWorld.addBehavior(rightLegJoin2)
        scene.physicsWorld.addBehavior(leftFootJoin)
        scene.physicsWorld.addBehavior(rightFootJoin)
        scene.physicsWorld.addBehavior(rightHandJoin)
        scene.physicsWorld.addBehavior(leftHandJoin)
        
        removableBehaviours.append(leftJoin)
        removableBehaviours.append(rightJoin)
        removableBehaviours.append(leftLegJoin)
        removableBehaviours.append(rightLegJoin)
        removableBehDict[leftJoin] = "leftArm"
        removableBehDict[rightJoin] = "rightArm"
        removableBehDict[leftLegJoin] = "leftLeg"
        removableBehDict[rightLegJoin] = "rightLeg"

        for i in figurine.childNodes {
            print(i.physicsBody?.velocity)
        }
    }
    
    func changeVelocity(){
        
        for body in figurine.childNodes {
            while !SCNVector3EqualToVector3(body.physicsBody!.velocityFactor, SCNVector3(1,1,1)){
                body.physicsBody?.velocityFactor = SCNVector3(1.0,1.0,1.0)
            }
            while !SCNVector3EqualToVector3(body.physicsBody!.angularVelocityFactor, SCNVector3(1,1,1)){
                body.physicsBody?.angularVelocityFactor = SCNVector3(1.0,1.0,1.0)
            }
            
            body.physicsBody!.contactTestBitMask = 11
            body.physicsBody!.categoryBitMask = 1
            body.physicsBody!.collisionBitMask = 1
        }
        
    }
    
    func fireShot(_ x: CGFloat, _ y: CGFloat){

        //print("ycko: \(y)")
        if firstTouch == false {

            changeVelocity()
            firstTouch = true
        }
        
        if !SCNVector3EqualToVector3(head.physicsBody!.velocityFactor, SCNVector3(1.0,1.0,1.0)){
            changeVelocity()
        }
        
                let chestXvalue: Float = 10
                let chestZValue: Float = 32
        
                let headYvalue: Float = 12
                let headZvalue: Float = 12
                let headXvalue: Float = 10
        
        var z = y
        if z < 0 {
            z = 0
        }
        
        
                        let chestX = countStrength(Float(x*1.2), chestXvalue, -chestXvalue, chestVelocity.x)
                        let chestZ = countStrength(Float(-z*1.2), chestZValue, -chestZValue, chestVelocity.z, true, true)
        
                        let headY = countStrength(Float(y*1.8), headYvalue, -headYvalue, headVelocity.y)
                        let headZ = countStrength(Float(-z*1.2), headZvalue, -headZvalue, headVelocity.z, true, true)
                        let headX = countStrength(Float(x*1.2), headXvalue, -headXvalue, headVelocity.x)
        
                chestTop.physicsBody?.velocity.z = chestZ
                chestTop.physicsBody?.velocity.x = chestX
        
                head.physicsBody?.velocity = SCNVector3(headX,headY,headZ)
    }
    
    private func countStrength(_ factor: Float, _ maximum: Float, _ minimum: Float, _ velocity: Float, _ zMax: Bool = false, _ zeroCheck: Bool = false) -> Float {
        
        var strength = velocity + (factor * maximum)
        if strength < minimum {
            if zMax {
                strength = minimum + (strength - minimum)/2
            } else {
                strength = minimum
            }
        } else if strength > maximum {
//            print("MAXIMUM \(strength),\(velocity),\(factor)")
            strength = maximum
        }
        if zeroCheck {
            if strength > 0 {
                strength = velocity
            }
        }
        
        return strength
}
    
    func restart() {
        gameRestart()
    }
    
    func fireBonus(name: String){
        
        //helping ball
        if name == "b1"{
            let ball = roadManager.templates.rootNode.childNode(withName: "bonusBall", recursively: true)?.clone()
            ball?.name = ""
            ball?.position = cameraHolder.position
            ball?.position.z -= 3
            
            let randY = randomCislo(rozsah: 4)
            var randX = randomCislo(rozsah: 3)
            if random50na50(){
                randX = -randX
            }
            ball?.physicsBody?.velocity.z = -55
            ball?.physicsBody?.velocity.y = Float(4 + randY)
            ball?.physicsBody?.velocity.x = Float(randX)
            scene.rootNode.addChildNode(ball!)
            
            //figurine turbo boost
        } else if name == "b2" {
            
            for i in figurine.childNodes {
                i.physicsBody?.applyForce(SCNVector3(0,2,-20), asImpulse: true)
            }
            
            //part of body falling, bad bonus
        } else {
            
            for _ in 0...1 {
            let index = randomCislo(rozsah: UInt32(removableBehaviours.count))
            switch removableBehDict[removableBehaviours[index]] {
            
            case "leftArm":
                leftArmTop.physicsBody?.contactTestBitMask = 0
                leftArmBottom.physicsBody?.contactTestBitMask = 0
                leftHand.physicsBody?.contactTestBitMask = 0
                break
            case "RightArm":
                rightArmTop.physicsBody?.contactTestBitMask = 0
                rightArmBottom.physicsBody?.contactTestBitMask = 0
                rightHand.physicsBody?.contactTestBitMask = 0
                break
            case "leftLeg":
                leftLegTop.physicsBody?.contactTestBitMask = 0
                leftLegBottom.physicsBody?.contactTestBitMask = 0
                leftFoot.physicsBody?.contactTestBitMask = 0
                break
            case "rightLeg":
                rightLegTop.physicsBody?.contactTestBitMask = 0
                rightLegBottom.physicsBody?.contactTestBitMask = 0
                rightFoot.physicsBody?.contactTestBitMask = 0
                break
            case .none: break
            
            case .some(_): break
                
            }
            
            scene.physicsWorld.removeBehavior(removableBehaviours[index])
            removableBehaviours.remove(at: index)
            }
            
            
            if removableBehaviours.count == 0 {
                
                scene.physicsWorld.removeAllBehaviors()
                print("GAME OVER")
                firstTouch = false
                gameOver()
                
            }
            
        }
    }
    
}
