//
//  Touch.swift
//  AirHockey
//
//  Created by Tomáš Macho on 13/06/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SpriteKit

protocol dotyk: class {
    func fireShot(_ x: CGFloat, _ y: CGFloat)
    func restart()
}

class Touch: SKScene, SKEffector {
    
    var gameOver: Bool = false
    var gamewin: Bool = false
    var user: UserDefaults = UserDefaults()
    
    var levelBar: SKSpriteNode!
    var actualLevel: SKLabelNode!
    var futureLevel: SKLabelNode!
    var filler: SKShapeNode!
    
    var tutorial: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var gameWinLabel: SKLabelNode!
    var actualScore: SKLabelNode!
    
    var restartLabel: SKLabelNode!
    
    weak var dotykDelegate: dotyk?
    var t = [UITouch:Int]()
    
    //iphone rozmery
    var iPhoneX: CGFloat!
    var height = CGFloat(1334)
    
    //suradnice - third version ovladanie
    var x0: CGFloat!
    var y0: CGFloat!
    
    override func didMove(to view: SKView) {

        self.scaleMode = .aspectFit
        self.view?.isMultipleTouchEnabled = false
        
        if self.frame.width/self.frame.height < 0.5 {
            iPhoneX = 145
        } else {
            iPhoneX = 0
        }
        
        initGUI()
        
    }
    
    func initGUI(){

        actualScore = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        actualScore.fontSize = 70
        actualScore.verticalAlignmentMode = .center
        actualScore.text = user.getActualScore()
        actualScore.position = CGPoint(x:self.frame.midX, y: self.frame.maxY - iPhoneX - height/6)
        self.addChild(actualScore)
        
    }
    
    //atacne levelbar a tutorial z menu
    func attachNodes(_ levelBar: SKSpriteNode,_ tutorial: SKLabelNode){

        self.levelBar = levelBar.copy() as! SKSpriteNode
        self.levelBar.removeFromParent()
        self.addChild(self.levelBar)
        
        self.filler = self.levelBar.childNode(withName: "filler") as! SKShapeNode
        
        self.actualLevel = self.levelBar.children[0].childNode(withName: "lvl") as! SKLabelNode
        self.futureLevel = self.levelBar.children[1].childNode(withName: "lvl") as! SKLabelNode
        
        self.tutorial = tutorial.copy() as! SKLabelNode
        self.tutorial.removeFromParent()
        self.tutorial.removeAllActions()
        self.addChild(self.tutorial)
        fadeOut(self.tutorial, 1)
    
    }
    
    func setLevelProgress(percentage: CGFloat){
        filler.xScale = percentage
    }
    
    func gameover(){

        gameOver = true
        
        let blesk = SKSpriteNode(color: .red, size: self.frame.size)
        blesk.position = CGPoint(x:self.frame.midX,y:self.frame.midY)
        blesk.alpha = 1
        self.addChild(blesk)
        fadeOut(blesk, 0.6, true, true)
        
        user.setActualScore(score: 0)
        
        gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        gameOverLabel.verticalAlignmentMode = .center
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 50
        gameOverLabel.alpha = 0
        gameOverLabel.position = CGPoint(x:self.frame.midX,y:self.frame.minY + height/8 + iPhoneX)
        self.addChild(gameOverLabel)
        
        blinking(gameOverLabel,0.3)
        
        restartLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        restartLabel.verticalAlignmentMode = .center
        restartLabel.text = "TAP TO RESTART"
        restartLabel.fontSize = 50
        restartLabel.alpha = 0
        restartLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(restartLabel)
        
        let wait = SKAction.wait(forDuration: 1.5)
        let fadein = SKAction.fadeIn(withDuration: 0.5)

        restartLabel.run(SKAction.sequence([wait,fadein]),withKey: "RESTART")
    }
    

    func gameWin(){
        gamewin = true
        
        let blesk = SKSpriteNode(color: .white, size: self.frame.size)
        blesk.position = CGPoint(x:self.frame.midX,y:self.frame.midY)
        blesk.alpha = 1
        self.addChild(blesk)
        fadeOut(blesk, 0.6, true, true)
        
        gameWinLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        gameWinLabel.verticalAlignmentMode = .center
        gameWinLabel.text = "LEVEL COMPLETE!"
        gameWinLabel.fontSize = 50
        gameWinLabel.alpha = 0
        gameWinLabel.position = CGPoint(x:self.frame.midX,y:self.frame.minY + height/8 + iPhoneX)
        self.addChild(gameWinLabel)
        
        blinking(gameWinLabel,0.3)
        
        //remove saved level a set actual score
        user.setLevelCompleted()
        user.setActualScore(score: Int(actualScore.text!)!)
        
        let wait = SKAction.wait(forDuration: 0.5)
        let downScale = SKAction.scale(to: 0, duration: 0.5)
        let upScale = SKAction.scale(to: 1, duration: 0.5)
        
        let run = SKAction.run {
            var lvl = Int(self.actualLevel.text!)
            lvl = lvl! + 1
            self.actualLevel.text = String(describing: lvl!)
            
            var lvl2 = Int(self.futureLevel.text!)
            lvl2 = lvl2! + 1
            self.futureLevel.text = String(describing: lvl2!)
        }
        
        self.run(SKAction.sequence([wait,wait,run]))
        self.actualLevel.run(SKAction.sequence([wait,downScale,upScale]))
        self.futureLevel.run(SKAction.sequence([wait,downScale,upScale]))
        self.filler.run(SKAction.sequence([wait,downScale]))
    }
    
    func plusScore(x: Float, y: Float, z: Float){
        
        var cislo = Int(actualScore.text!)
        cislo = cislo! + 1
        actualScore.text = String(describing: cislo!)
        bumpNode(node: actualScore, velkost: 2.5, cas: 0.1, casSpat: 0.3)
        
        //plus ONE label
        let plusLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        plusLabel.text = "+1"
        
        var magnifier = z/50
        if magnifier > 1 {
            magnifier = 1
        } else if magnifier < 0 {
            magnifier = 0
        }
        
        plusLabel.fontSize = CGFloat(110 - magnifier*80)

        let min = (self.frame.minY + iPhoneX + height/5)
        
        let distance = height/3 * CGFloat(magnifier)
       
        let yPosition = min + distance
        
        var magnifier2 = x/10
        if(magnifier2 > 1){
            magnifier2 = 1
        } else if magnifier2 < -1 {
            magnifier2 = -1
        }
        
        let xPosition = self.frame.midX + CGFloat(magnifier2) * self.frame.width/2.2
        plusLabel.position = CGPoint(x: xPosition, y: yPosition)
        self.addChild(plusLabel)
        
        let move = SKAction.moveBy(x: 0, y: height/6, duration: 1)
        move.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let die = SKAction.removeFromParent()
        plusLabel.run(SKAction.sequence([SKAction.group([move,fadeOut]),die]))
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if !gameOver && !gamewin {
        for touch in touches {

            //THIRD VERSION
            let location = touch.location(in: self)
            x0 = location.x
            y0 = location.y
            
        }
        } else if gameOver && restartLabel?.action(forKey: "RESTART") == nil {
            
           dotykDelegate?.restart()
            return
            
        }
    
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !gameOver && !gamewin {
            for touch in touches {
                
              let location = touch.location(in: self)
              let xDiff = (location.x - x0)/100
              let yDiff = (location.y - y0)/100
                
                
                x0 = location.x
                y0 = location.y
                
                dotykDelegate?.fireShot(xDiff, yDiff)
                
                
            }
        
    }
    
}
}
