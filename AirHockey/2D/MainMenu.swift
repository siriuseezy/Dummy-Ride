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
    
    var started: Bool = false
    
    //iphone rozmery
    var iPhoneX: CGFloat!
    var height = CGFloat(1334)
    
    override func didMove(to view: SKView) {

        self.scaleMode = .aspectFit
        self.view?.isMultipleTouchEnabled = false
        
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
        
      let lvl = SKLabelNode(fontNamed: "HelveticaNeue")
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
        
        let lvlF = SKLabelNode(fontNamed: "HelveticaNeue")
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
        
        tutorial = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        tutorial.verticalAlignmentMode = .center
        tutorial.text = "SWIPE TO MOVE"
        tutorial.fontSize = 50
        tutorial.position = CGPoint(x:self.frame.midX,y:self.frame.minY + height/8 + iPhoneX)
        self.addChild(tutorial)
        
        blinking(tutorial,0.3)
        
    }
    
    func initScore(){
        
        actualScore = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        actualScore.fontSize = 70
        actualScore.verticalAlignmentMode = .center
        actualScore.text = user.getActualScore()
        actualScore.position = CGPoint(x:self.frame.midX, y: self.frame.maxY - iPhoneX - height/6)
        self.addChild(actualScore)
        
    }
    
    func initHighScore(){
        
        let user = UserDefaults()
        let value = user.integer(forKey: "highScore")
        
        highScore = SKLabelNode(fontNamed: "HelveticaNeue")
        highScore.verticalAlignmentMode = .center
        highScore.text = "TOP: " + String(value)
        highScore.fontSize = 60
        highScore.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - iPhoneX - height/4)
        self.addChild(highScore)
        
        
        
    }

}
