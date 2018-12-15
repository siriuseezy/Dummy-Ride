//
//  PhysicsCreator.swift
//  AirHockey
//
//  Created by Tomáš Macho on 17/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit

protocol PhysicsCreator {
    
    func attachDynamicBody(_ node: SCNNode, _ mass: CGFloat, _ frict: CGFloat, _ rest: CGFloat, _ rollFrict: CGFloat, _ damp: CGFloat, _ angDamp: CGFloat, _ contact: Int)
    
}

extension PhysicsCreator {
    
    func attachDynamicBody(_ node: SCNNode, _ mass: CGFloat, _ frict: CGFloat, _ rest: CGFloat, _ rollFrict: CGFloat, _ damp: CGFloat, _ angDamp: CGFloat, _ contact: Int){
        
        let body = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: node.geometry!)
        )

        body.mass = mass
        body.friction = frict
        body.restitution = rest
        body.rollingFriction = rollFrict
        body.damping = damp
        body.angularDamping = angDamp
        
        body.contactTestBitMask = contact

        node.physicsBody = body
        
    }
    
    func attachStaticBody(_ node: SCNNode, _ frict: CGFloat, _ rest: CGFloat, _ rollFrict: CGFloat, _ damp: CGFloat, _ angDamp: CGFloat, _ category: Int, _ collision: Int, _ contact: Int){
        
        let body = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: node.geometry!)
        )
        
        body.friction = frict
        body.restitution = rest
        body.rollingFriction = rollFrict
        body.damping = damp
        body.angularDamping = angDamp
        
        body.categoryBitMask = category
        body.collisionBitMask = collision
        body.contactTestBitMask = contact
        
        node.physicsBody = body
        
    }
    
    
    
    
}
