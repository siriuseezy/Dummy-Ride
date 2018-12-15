//
//  RoadCamera.swift
//  AirHockey
//
//  Created by Tomáš Macho on 25/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//
import SceneKit
import Foundation

extension Road {
    
    func placeFigurine(){
        
        cameraHolder.removeAction(forKey: "following")
        let cameraDistanceFromFigurine: Float = 28
        let road = LEVEL?.level.childNode(withName: "base", recursively: true)!.geometry as! SCNBox
        figurine.position = SCNVector3(0,0,Float((road.length - startBox)/2))
        rootNode.addChildNode(figurine)

        //sledovanie kamerou
        let action = SCNAction.run{ _ in
            
            var z = self.figurine.childNode(withName: "head", recursively: true)!.presentation.convertPosition(SCNVector3(0,0,0), to: self.cameraHolder).z + cameraDistanceFromFigurine
            if z > 0 && z < 20 {
                z = 0
            }
            
            let x = self.figurine.childNode(withName: "chestTop", recursively: true)!.presentation.convertPosition(SCNVector3(0,0,0), to: self.cameraHolder).x
            self.cameraHolder.eulerAngles.y = -Float(Double.pi/20 * Double(x/10))
            self.cameraHolder.position.z += z
            
        }
        
        let wait = SCNAction.wait(duration: 1/60)
        cameraHolder.runAction(SCNAction.repeatForever(SCNAction.sequence([action,wait])),forKey: "following")
        
        
    }
    
}
