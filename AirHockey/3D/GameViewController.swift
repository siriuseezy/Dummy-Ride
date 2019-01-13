//
//  GameViewController.swift
//  AirHockey
//
//  Created by Tomáš Macho on 13/06/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController, PhysicsCreator, ScnEffector, Randomizator, SCNSceneRendererDelegate{
    
    //sceny
    var roadManager: Road!
    let scene:SCNScene = SCNScene(named: "art.scnassets/game.scn")!
    let source:SCNScene = SCNScene(named: "art.scnassets/road.scn")!
    var scnView:SCNView!
    
    var skMenu: MainMenu!
    var skGame: Touch!
    
    var road: SCNNode!
    var cameraHolder: SCNNode!
    
    //user
    let user = UserDefaults()
    
    //casti figuriny
    var figurine: SCNNode!
    var head: SCNNode!
    var chestTop: SCNNode!
    var chestBottom: SCNNode!
    var leftArmTop: SCNNode!
    var leftArmBottom: SCNNode!
    var rightArmTop: SCNNode!
    var rightArmBottom: SCNNode!
    var leftLegTop: SCNNode!
    var rightLegTop: SCNNode!
    var leftLegBottom: SCNNode!
    var rightLegBottom: SCNNode!
    var leftFoot: SCNNode!
    var rightFoot: SCNNode!
    var leftHand: SCNNode!
    var rightHand: SCNNode!
    
    ///added behaviours
    var removableBehaviours: [SCNPhysicsBehavior] = []
    var removableBehDict: [SCNPhysicsBehavior:String] = [:]
    
    //hybnost panaka
    var chestVelocity: SCNVector3!
    var headVelocity: SCNVector3!
    
    var firstTouch: Bool = false
    var isPlaying: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if skMenu != nil {
            skMenu.started = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        scnView = self.view as! SCNView
        
        setupScreenSize()
        
        //DEVEL
        //user.removeGeneratedLevel()
        
        skMenu = MainMenu(size: returnSize())
        skMenu.dotykDelegate = self
        
        initialSetup()
        setupCamera()
        createBody()
        roadManager = Road(rootNode: self.scene.rootNode, cameraHolder: cameraHolder, figurine: figurine)
        start()
    }
    
    
    // MARK: on start
    
    func setupScreenSize(){
        
        let screenSizeRatio = user.float(forKey: "screenSizeRatio")
        if screenSizeRatio == 0 {
            user.set(self.view.frame.width/self.view.frame.height, forKey: "screenSizeRatio")
        }
        
    }
    
    func initialSetup(){

    scnView.scene = scene
    scnView.scene?.physicsWorld.speed = 2.1
    scnView.allowsCameraControl = false
    scnView.showsStatistics = false
    scnView.overlaySKScene = skMenu
    scnView.isPlaying = true
    scnView.scene?.physicsWorld.contactDelegate = self
    scnView.delegate = self
        
    NotificationCenter.default.addObserver(self, selector: #selector(doneCreatingRoad), name: NSNotification.Name(rawValue: "doneCreatingRoad"), object: nil)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if head != nil {
            chestVelocity = chestTop.physicsBody?.velocity
            headVelocity = head.physicsBody?.velocity
        }
        
    }
    
    func setupCamera(){
        cameraHolder = source.rootNode.childNode(withName: "cameraHolder", recursively: true)!.clone()
        cameraHolder.position = source.rootNode.childNode(withName: "cameraHolder", recursively: true)!.position
        scene.rootNode.addChildNode(cameraHolder)
        scnView.pointOfView = cameraHolder.childNode(withName: "camera", recursively: true)!
    }
    
    func start(){
        
          roadManager.loadRoad()
          changeBackground()
          roadManager.placeRoad()
          self.road = roadManager.LEVEL?.level
          roadManager.placeFigurine()
     
    }
    
    func returnSize() -> CGSize {

        if user.float(forKey: "screenSizeRatio") < 0.5 {
            return CGSize(width: 750, height: 1624)
        } else {
            return  CGSize(width: 750, height: 1334)
        }
        
        
    }
    
    func changeBackground(){
        
        let layer1 = CAGradientLayer()
        layer1.colors = [roadManager.LEVEL!.backgroundColors.color1.cgColor,roadManager.LEVEL!.backgroundColors.color2.cgColor]
        layer1.bounds = CGRect(x: 0, y: 0, width: 500, height: 500)
      
        let layer2 = CALayer()
        layer2.backgroundColor = roadManager.LEVEL?.backgroundColors.color1.cgColor
        layer2.bounds = CGRect(x: 0, y: 0, width: 500, height: 500)

        let layer3 = CALayer()
        layer3.backgroundColor = roadManager.LEVEL?.backgroundColors.color2.cgColor
        layer3.bounds = CGRect(x: 0, y: 0, width: 500, height: 500)
        
        let image1 = UIImage.image(from: layer1)
        let image2 = UIImage.image(from: layer2)
        let image3 = UIImage.image(from: layer3)
        
        scene.background.contents = [image1,image1,image3,image2,image1,image1]
        //right, left, top, bottom, back, front
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

extension GameViewController: starter {
    
    // MARK : game
    
    func startGame(levelBar: SKSpriteNode, tutorial: SKLabelNode) {

         isPlaying = true
         roadManager.cameraHolder.childNode(withName: "camera", recursively: true)!.childNodes[0].name = "cameraSMRT"
         skGame = Touch(size: returnSize())
         skGame.attachNodes(levelBar, tutorial)
         skGame.dotykDelegate = self
         scnView.overlaySKScene = skGame
         runProgressBar()
        
         //GAME ANALYTICS
         let level = Int(skGame.actualLevel.text!)!
         let score = Int(skGame.actualScore.text!)!
         GameAnalytics.addProgressionEvent(with: GAProgressionStatusStart, progression01: "game", progression02: "LEVEL" + String(level), progression03: "", score: score)
        
    }
    
    //ukazovatel progressu
    func runProgressBar(){
        let base = road.childNode(withName: "base", recursively: true)!
        let baseGeo = base.geometry as! SCNBox
        let length = Float(baseGeo.length) - 40 //+ 40 za podlohu pred panakou

        let action = SCNAction.run{ _ in
            
            let headZ = self.head.presentation.convertPosition(SCNVector3(0,0,0), to: self.scene.rootNode).z
            let distance = headZ - (-length/2)
            var percentage = 1 - CGFloat(distance/length)
            if percentage > 1 {
                percentage = 1
            }
            self.skGame.setLevelProgress(percentage: percentage)
            
        }
        
        let wait = SCNAction.wait(duration: 1/5)
        
        self.scene.rootNode.runAction(SCNAction.repeatForever(SCNAction.sequence([action,wait])), forKey: "progressBar")
        
    }
    
    //po vyhrati levelu nastane slow down a spusti sa novy level. aj pri zobrati bonusu sa opatovne vykona toto
    func slowDownAndRunNewLevel(time: TimeInterval){
        
        let run = SCNAction.run({_ in
            
            self.roadManager.removeRoad()
            self.roadManager.levelCompleted()
            self.roadManager.loadRoad(repeatLoad: true)
            
        })
        
        let speed = self.scene.physicsWorld.speed
        
        let slowDown = SCNAction.customAction(duration: time) {(nil, elapsedTime) -> () in
            self.scene.physicsWorld.speed = speed - ((elapsedTime/CGFloat(time)) * speed)
        }
        
        self.scene.rootNode.runAction(SCNAction.sequence([slowDown,run]), forKey: "gameWinScene")
        
    }
    
    func diamondCollected(){
        skGame.plusDiamond()
        user.set(true, forKey: "firstGem")
        user.set(true, forKey: "gemCollected")
        
        if(skGame.actualScore != nil){
           user.checkHighScore(score: Int(skGame.actualScore.text!)!)
        }
        
       self.scene.rootNode.removeAction(forKey: "gameWinScene")
       slowDownAndRunNewLevel(time: 3)
       
    }
    
    
    func gameFinished(win: Bool) -> Bool {

        //GAME ANALYTICS
        let level = Int(skGame.actualLevel.text!)!
        var score = 0
        
        var newHighScore = false
        self.firstTouch = false
    
        if(skGame.actualScore != nil){
        newHighScore = user.checkHighScore(score: Int(skGame.actualScore.text!)!)
            score = Int(skGame.actualScore.text!)!
        }
        
        //GAME ANALYTICS
        if win {
        GameAnalytics.addProgressionEvent(with: GAProgressionStatusComplete, progression01: "game", progression02: "LEVEL" + String(level), progression03: "", score: score)
        } else {
        GameAnalytics.addProgressionEvent(with: GAProgressionStatusFail, progression01: "game", progression02: "LEVEL" + String(level), progression03: "", score: score)
        }
        
        
        
        self.scene.rootNode.removeAction(forKey: "progressBar")
        isPlaying = false
        roadManager.cameraHolder.childNode(withName: "camera", recursively: true)!.childNodes[0].name = "NILcameraSMRT"
        return newHighScore
    }
    
    func gameWin(){
        cameraHolder.removeAction(forKey: "following")
        let move = SCNAction.move(by: SCNVector3(x:0,y:0,z:-20), duration: 1)
        move.timingMode = .easeOut
        cameraHolder.runAction(move)

        for i in figurine.childNodes{
            i.physicsBody?.contactTestBitMask = 128
        }
        
        user.removeGeneratedLevel()
        gameFinished(win: true)
        skGame.gameWin()
        slowDownAndRunNewLevel(time: 4)
    }
    
    func gameOver(reason: Int){
        
        for i in figurine.childNodes{
            i.physicsBody?.contactTestBitMask = 0
        }
        
        let newHighScore = gameFinished(win: false)
        DispatchQueue.main.async{
            self.skGame.gameover(newRecord: newHighScore, reason: reason)
        }
        
        self.scene.physicsWorld.speed = 0.04
        let wait = SCNAction.wait(duration: 1.5)
        let slowDown = SCNAction.customAction(duration: 1.5) {(nil, elapsedTime) -> () in
            self.scene.physicsWorld.speed = 2.1 - ((elapsedTime/1.5) * 2.1)
        }
        self.scene.rootNode.runAction(SCNAction.sequence([wait,slowDown]))
    }
    
    func gameRestart(){
        
        let run = SCNAction.run({   _ in
            
            self.roadManager.removeRoad()
            self.roadManager.loadRoad(repeatLoad: true)
        })
        self.scene.rootNode.runAction(run)
    }
    
    @objc func doneCreatingRoad(){
        
            createBody()
        
            self.skMenu = MainMenu(size: self.returnSize())
            self.skMenu.dotykDelegate = self
            self.scnView.overlaySKScene = self.skMenu
            self.scnView.scene?.physicsWorld.speed = 2.1
            self.skMenu.started = true
            
            self.changeBackground()
            self.roadManager.placeRoad()
        
            self.road = self.roadManager.LEVEL?.level
            
            self.roadManager.figurine = self.figurine
           
            self.roadManager.placeFigurine()
        

    }


    
}
