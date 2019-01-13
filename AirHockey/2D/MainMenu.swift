//
//  MainMenu.swift
//  AirHockey
//
//  Created by Tomáš Macho on 24/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

//
//  SKSceneSetup.swift
//  AirHockey
//
//  Created by Tomáš Macho on 24/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SpriteKit

protocol starter: class {
    func startGame(levelBar: SKSpriteNode, tutorial: SKLabelNode)
}

class MainMenu: SKScene, SKEffector {
    
    weak var dotykDelegate: starter?
    
    var t = [UITouch:Int]()
    var user: UserDefaults = UserDefaults()
    
    var levelBar: SKSpriteNode!
    var actualLevel: SKShapeNode!
    var futureLevel: SKShapeNode!
    
    var tutorial: SKLabelNode!
    var highScore: SKLabelNode!
    var actualScore: SKLabelNode!
    var finger: SKSpriteNode!

    var started: Bool = false
    
    //iphone rozmery
    var iPhoneX: CGFloat!
    var height = CGFloat(1334)
    
    override func didMove(to view: SKView) {

        self.scaleMode = .aspectFit
        DispatchQueue.main.async {
        self.view?.isMultipleTouchEnabled = false
        }
        
        if self.frame.width/self.frame.height < 0.5 {
            iPhoneX = 145
        } else {
            iPhoneX = 0
        }
        
        initLevelizator()
        initTutorial()
        initScore()
        initHighScore()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if started {
        for touch in touches {
            dotykDelegate?.startGame(levelBar: levelBar, tutorial: tutorial)
            return
        }
        }
    }
    
    func initLevelizator(){
        
      let user = UserDefaults()
        
      levelBar = SKSpriteNode(color: .clear, size: CGSize(width: self.frame.width, height: 150))
      levelBar.position = CGPoint(x: self.frame.midX,y: self.frame.maxY - height/13 - iPhoneX)
      self.addChild(levelBar)
        
      actualLevel = SKShapeNode(circleOfRadius: 33)
      actualLevel.fillColor = UIColor(red:6/255, green: 0, blue: 255/255, alpha: 1)
      actualLevel.lineWidth = 4
      actualLevel.position = CGPoint(x: -170, y: 0)
      levelBar.addChild(actualLevel)
        
//      let lvl = SKLabelNode(fontNamed: "HelveticaNeue")
        let lvl = SKLabelNode(fontNamed: "SF Atarian System")
          lvl.text = String(user.retrieveActualLevel())
          lvl.name = "lvl"
          lvl.fontSize = 37
          lvl.verticalAlignmentMode = .center
      actualLevel.addChild(lvl)
        
        futureLevel = SKShapeNode(circleOfRadius: 33)
        futureLevel.fillColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.7)
        futureLevel.lineWidth = 4
        futureLevel.position = CGPoint(x: 170, y: 0)
        levelBar.addChild(futureLevel)
        
//        let lvlF = SKLabelNode(fontNamed: "HelveticaNeue")
        let lvlF = SKLabelNode(fontNamed: "SF Atarian System")
        lvlF.verticalAlignmentMode = .center
        lvlF.text = String(user.retrieveActualLevel() + 1)
        lvlF.fontSize = 37
        lvlF.name = "lvl"
        futureLevel.addChild(lvlF)
        
        let upStick = SKShapeNode(rectOf: CGSize(width: 280, height: 1.5))
        upStick.fillColor = .white
        let downStick = SKShapeNode(rectOf: CGSize(width:280, height: 1.5))
        downStick.fillColor = .white
        upStick.position = CGPoint(x:0,y:10)
        downStick.position = CGPoint(x:0,y:-10)
        
        levelBar.addChild(upStick)
        levelBar.addChild(downStick)
        
        let filler = SKShapeNode(rectOf: CGSize(width: 280, height: 10))
        filler.name = "filler"
        filler.fillColor = .white
        filler.position = CGPoint(x:0,y:0)
        levelBar.addChild(filler)
        
        filler.xScale = 0
      }
    
    func initTutorial(){
        
//        tutorial = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        tutorial = SKLabelNode(fontNamed: "SF Atarian System")
        tutorial.verticalAlignmentMode = .center
        tutorial.text = "SWIPE TO MOVE"
        tutorial.fontSize = 65
        tutorial.position = CGPoint(x:self.frame.midX,y:self.frame.minY + height/8 + iPhoneX)
        self.addChild(tutorial)
        
        blinking(tutorial,0.3)
        
        finger = SKSpriteNode(imageNamed: "finger")
        finger.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.minY + height/8 + iPhoneX)
        finger.setScale(0.5)
        finger.alpha = 0.6
        finger.zRotation = .pi/4
        
        let move1a = SKAction.move(by: CGVector(dx: 20, dy: 80), duration: 0.5)
        let move1b = SKAction.move(by: CGVector(dx: -20, dy: -80), duration: 0.5)
        let move2a = SKAction.move(by: CGVector(dx: 0, dy: 80), duration: 0.5)
        let move2b = SKAction.move(by: CGVector(dx: 0, dy: -80), duration: 0.5)
        let move3a = SKAction.move(by: CGVector(dx: -20, dy: 80), duration: 0.5)
        let move3b = SKAction.move(by: CGVector(dx: 20, dy: -80), duration: 0.5)
        self.addChild(finger)
        finger.run(SKAction.repeatForever(SKAction.sequence([move1a,move1b,move2a,move2b,move3a,move3b])))
        
    }
    
    func initScore(){
        
//        actualScore = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        actualScore = SKLabelNode(fontNamed: "SF Atarian System Bold")
        actualScore.fontSize = 70
        actualScore.verticalAlignmentMode = .center
        actualScore.text = user.getActualScore()
        actualScore.position = CGPoint(x:self.frame.midX, y: self.frame.maxY - iPhoneX - height/6)
        self.addChild(actualScore)
        
    }
    
    func initHighScore(){
        
        let user = UserDefaults()
        let value = user.integer(forKey: "highScore")
        
//        highScore = SKLabelNode(fontNamed: "HelveticaNeue")
        highScore = SKLabelNode(fontNamed: "SF Atarian System")
        highScore.verticalAlignmentMode = .center
        highScore.text = "TOP: " + String(value)
        highScore.fontSize = 80
        highScore.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - iPhoneX - height/4)
        self.addChild(highScore)

    }

}
