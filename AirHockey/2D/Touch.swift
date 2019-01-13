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

class Touch: SKScene, SKEffector, Randomizator {
    
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
    var newHighScoreLabel: SKLabelNode!
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
    
    //multiplier
    var scoreMultiplier: Int = 1
    
    //debugging
//    var test: SKLabelNode!
    
    override func didMove(to view: SKView) {

        self.scaleMode = .aspectFit
        self.view?.isMultipleTouchEnabled = false
        
        if self.frame.width/self.frame.height < 0.5 {
            iPhoneX = 145
        } else {
            iPhoneX = 0
        }
        
        initGUI()
//        initTest()
        
    }
    
//    func initTest(){
//
//        test = SKLabelNode(fontNamed: "SF Atarian System")
//        test.verticalAlignmentMode = .center
//        test.text = ""
//        test.fontSize = 80
//        test.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - iPhoneX - height/4)
//        self.addChild(test)
//
//    }
    
    func initGUI(){

//        actualScore = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        actualScore = SKLabelNode(fontNamed: "SF Atarian System Bold")
        actualScore.fontSize = 80
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
    
    func gameover(newRecord: Bool,reason: Int){

        gameOver = true
        
        colorFlare(color: .red, alpha: 1, time: 0.6, moveUpside: false)
        
        user.setActualScore(score: 0)
        
//        gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        gameOverLabel = SKLabelNode(fontNamed: "SF Atarian System")
        gameOverLabel.verticalAlignmentMode = .center
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 60
        gameOverLabel.alpha = 0
        gameOverLabel.position = CGPoint(x:self.frame.midX,y:self.frame.minY + height/8 + iPhoneX)
        self.addChild(gameOverLabel)
        
        blinking(gameOverLabel,0.3)
        
//        restartLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        restartLabel = SKLabelNode(fontNamed: "SF Atarian System")
        restartLabel.verticalAlignmentMode = .center
        restartLabel.text = "TAP TO RESTART"
        restartLabel.fontSize = 60
        restartLabel.alpha = 0
        restartLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(restartLabel)
        
        let wait = SKAction.wait(forDuration: 2.6)
        let fadein = SKAction.fadeIn(withDuration: 0.5)

        restartLabel.run(SKAction.sequence([wait,fadein]),withKey: "RESTART")
        
        ///CAMERA HIT!
        if reason == 2 {
            let gameOverMessage = SKLabelNode(fontNamed: "SF Atarian System Bold")
            gameOverMessage.fontSize = 80
            gameOverMessage.verticalAlignmentMode = .center
            gameOverMessage.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
            gameOverMessage.text = "SCREEN HIT!"
            gameOverMessage.fontColor = UIColor.white
            self.addChild(gameOverMessage)
            
            let child = SKLabelNode(fontNamed: "SF Atarian System Bold")
            child.fontSize = 80
            child.verticalAlignmentMode = .center
            child.position = CGPoint(x:2,y:0)
            child.fontColor = UIColor.black
            child.zPosition = -1
            child.text = "SCREEN HIT!"
            gameOverMessage.addChild(child)
            
            let wait = SKAction.wait(forDuration: 1.5)
            let fadeOut = SKAction.fadeOut(withDuration: 1)
            gameOverMessage.run(SKAction.sequence([wait,fadeOut]))
            
            shaking(gameOverMessage, time: 0.3,vector: CGVector(dx: 30, dy: 0),count: 3)
        }
        
        if newRecord {

            newHighScoreLabel = SKLabelNode(fontNamed: "SF Atarian System Bold")
            newHighScoreLabel.verticalAlignmentMode = .center
            newHighScoreLabel.text = "NEW BEST SCORE!"
            newHighScoreLabel.fontSize = 80
            newHighScoreLabel.alpha = 0
            newHighScoreLabel.setScale(0.2)
            newHighScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - height/4 - iPhoneX)
            self.addChild(newHighScoreLabel)
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1, duration: 0.5)
            newHighScoreLabel.run(SKAction.group([fadeIn,scaleUp]))
            
            if let fireWorks = SKEmitterNode.init(fileNamed: "fireWorks.sks"){
                fireWorks.numParticlesToEmit = 1500
                fireWorks.particlePositionRange.dx = self.frame.width/1.2
                fireWorks.position = CGPoint(x:self.frame.midX, y: self.frame.maxY - height/4 - iPhoneX + 15)
                fireWorks.zPosition = -1
                fireWorks.targetNode = self.scene
                self.addChild(fireWorks)
                let die = SKAction.wait(forDuration: 5)
                let remove = SKAction.removeFromParent()
                fireWorks.run(SKAction.sequence([die,remove]))
            }
            
            
        }
    }
    
    func gameWin(){
        gamewin = true
        
        colorFlare(color: .white, alpha: 1, time: 0.6, moveUpside: false)
        
//        gameWinLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        gameWinLabel = SKLabelNode(fontNamed: "SF Atarian System")
        gameWinLabel.verticalAlignmentMode = .center
        gameWinLabel.text = "LEVEL COMPLETE!"
        gameWinLabel.fontSize = 60
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
    
    func plusDiamond(){
        var cislo = Int(actualScore.text!)
        cislo = cislo! + 250
        actualScore.text = String(describing: cislo!)
        bumpNode(node: actualScore, velkost: 3.5, cas: 0.1, casSpat: 0.7)
        
        let plusLabel = SKLabelNode(fontNamed: "SF Atarian System Bold")
        plusLabel.text = "BONUS +250"
        plusLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - height/2.5 - iPhoneX)
        plusLabel.fontSize = 100
        self.addChild(plusLabel)
        
        let move = SKAction.moveBy(x: 0, y: height/6, duration: 2.3)
        move.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 2.3)
        let die = SKAction.removeFromParent()
        plusLabel.run(SKAction.sequence([SKAction.group([move,fadeOut]),die]))
        
        user.setActualScore(score: Int(actualScore.text!)!)
    }
    
    func showAwesome(){
        
        if let plusLabel = self.childNode(withName: "awesome") as?  SKLabelNode {
            
            plusLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + height/2.5 + iPhoneX)
            self.removeAction(forKey: "bonusFactor")
            plusLabel.alpha = 0.9
            var number = Int(String((plusLabel.text!.suffix(2).prefix(1))))!
            number += 1
            if number > 9 {
                number = 9
            }
            scoreMultiplier = number
            
            plusLabel.text = "COMBO " + String(number) + "x"
            
            
        } else {
            
            let plusLabel = SKLabelNode(fontNamed: "SF Atarian System Bold")
            plusLabel.name = "awesome"
            plusLabel.alpha = 0.9
            plusLabel.text = "COMBO 1x"
            plusLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + height/2.5 + iPhoneX)
            plusLabel.fontSize = 90
            self.addChild(plusLabel)
    
        }
        
        let move = SKAction.moveBy(x: 0, y: -height/7, duration: 4.5)
        move.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 4.5)
        let die = SKAction.removeFromParent()
        let run = SKAction.run {
            self.scoreMultiplier = 1
        }
        self.childNode(withName: "awesome")?.run(SKAction.sequence([SKAction.group([move,fadeOut]),die,run]), withKey: "bonusFactor")
        
    }
    
    func plusScore(x: Float, y: Float, z: Float){
        
        if actualScore != nil {
        var cislo = Int(actualScore.text!)
        cislo = cislo! + scoreMultiplier
        actualScore.text = String(describing: cislo!)
        bumpNode(node: actualScore, velkost: 2.5, cas: 0.1, casSpat: 0.3)
        
        //plus X label
        let plusLabel = SKLabelNode(fontNamed: "SF Atarian System Bold")
        
        plusLabel.text = "+" + String(scoreMultiplier)
        
        var magnifier = z/50
        if magnifier > 1 {
            magnifier = 1
        } else if magnifier < 0 {
            magnifier = 0
        }
        
        plusLabel.fontSize = CGFloat(130 - magnifier*80)

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
    }
    
    func colorFlare(color: UIColor, alpha: CGFloat, time: TimeInterval, moveUpside: Bool){
        
        let flare = SKSpriteNode(color: color, size: self.frame.size)
        flare.position = CGPoint(x:self.frame.midX,y:self.frame.midY)
        flare.alpha = alpha
        self.addChild(flare)
        fadeOut(flare, time, true, true)
        if moveUpside {
            moveBy(flare,CGVector(dx: 0, dy: self.frame.height),time)
        }
        
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
