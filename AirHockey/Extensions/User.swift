//
//  User.swift
//  AirHockey
//
//  Created by Tomáš Macho on 24/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit

extension UserDefaults {
    
    //2D////
    func retrieveActualLevel() -> Int {
        return integer(forKey: "actualLevel") + 1
    }
    
    func setLevelCompleted(){
        let level = integer(forKey: "actualLevel") + 1
        set(level, forKey: "actualLevel")
    }
    
    func checkHighScore(score: Int){
        let hs = integer(forKey: "highScore")
        if score > hs {
            set(score, forKey: "highScore")
        }
    }
    
    func getActualScore() -> String {
        
        let score = integer(forKey: "actualScore")
        return String(score)
        
    }
    
    func setActualScore(score: Int){
        set(score, forKey: "actualScore")
    }
    
    //3D///
    func saveGeneratedLevel(level: Level){

        let nodeData = NSKeyedArchiver.archivedData(withRootObject: level.level)
        let color1 = NSKeyedArchiver.archivedData(withRootObject: level.backgroundColors.color1)
        let color2 = NSKeyedArchiver.archivedData(withRootObject: level.backgroundColors.color2)
        set(nodeData, forKey: "actualLevelNode")
        set(color1, forKey: "bgcl1")
        set(color2, forKey: "bgcl2")
    }
    
    func retrieveGeneratedLevel() -> Level? {

        let node = self.object(forKey: "actualLevelNode") as? NSData
        let color1 = self.object(forKey: "bgcl1") as? NSData
        let color2 = self.object(forKey: "bgcl2") as? NSData

        
        if node != nil {
        let level = NSKeyedUnarchiver.unarchiveObject(with: node! as Data) as? SCNNode
        let color1 = NSKeyedUnarchiver.unarchiveObject(with: color1! as Data) as? UIColor
        let color2 = NSKeyedUnarchiver.unarchiveObject(with: color2! as Data) as? UIColor

        
        if level == nil {
            return nil
        } else {
            
            let levelCopy = Level()
            levelCopy.level = level!.clone()
            levelCopy.backgroundColors = backgroundColors(color1: color1,color2: color2)
            return levelCopy
        }
        } else {
            return nil
        }

    }
    
    func removeGeneratedLevel(){
        removeObject(forKey: "actualLevelNode")
    }
}
