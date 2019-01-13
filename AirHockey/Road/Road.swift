//
//  Road.swift
//  AirHockey
//
//  Created by Tomáš Macho on 19/07/2018.
//  Copyright © 2018 Tomáš Macho. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

struct space {
    let min: SCNVector3
    let max: SCNVector3
}

struct UsedPresets {
    let folder: Int
    let block: Int
}

//PRI GAME OVERI ALEBO GAME WIN OSETRTIT UPLNE PRERUSENIE HRY! idealne vypnut physics contact delegate alebo nieco 

class Road: Randomizator, PhysicsCreator, ScnEffector {
    
    let source:SCNScene = SCNScene(named: "art.scnassets/road.scn")!
    let templates: SCNScene = SCNScene(named: "art.scnassets/templates.scn")!
    var sourceFolders: [SCNNode] = []
    
    var LEVEL: Level?
    //index of block parent in level children array
    var nodeBlockDict: Dictionary<Int,Int> = [:]
    var livingNodes: Dictionary<SCNNode,Dictionary<SCNNode,Bool>> = [:]
    
    //for not repeating content
    var usedPresets: [UsedPresets] = []
    
    //for maximum 'X' bonuses
    var crossBonuses: Int = 0
    
    let user = UserDefaults()
    var rootNode: SCNNode!
    var figurine: SCNNode!
    var cameraHolder: SCNNode!
    var camera: SCNNode!
    
    //
    
    let startBox: CGFloat = 40
    
    //percentualne sance
    let objectCounts = [40,50,60,65,100]
    
    init(rootNode: SCNNode, cameraHolder: SCNNode, figurine: SCNNode){
        
        for i in templates.rootNode.childNodes {
            if (i.name?.starts(with: "temp"))!{
                sourceFolders.append(i)
            }
        }
        
        //
        
        self.rootNode = rootNode
        self.cameraHolder = cameraHolder
        self.camera = cameraHolder.childNode(withName: "camera", recursively: true)!.childNodes.first
        self.figurine = figurine
        
    }
    
    ////// ////// ////// ////// ////// ////// //////
    
    func levelCompleted(){
        user.removeGeneratedLevel()
    }
    
    func loadRoad(repeatLoad: Bool = false){

        let savedNode = user.retrieveGeneratedLevel()
        
        if (savedNode == nil){
            //GENERATE WORLD
            
            generateRoad()
            
            let level = user.retrieveGeneratedLevel()
            if level != nil {
            LEVEL = level
                
            }
            
        } else {
            
            //ALREADY GENERATED
            LEVEL = savedNode
            
        }
        
        if repeatLoad {
            NotificationCenter.default.post(name: NSNotification.Name("doneCreatingRoad"), object: nil)
        }
    }
    
    func placeRoad(){
        
        //umiestnenie road
        if LEVEL != nil {
            rootNode.addChildNode(LEVEL!.level)
        }
        
        //init dictionaries kvoli bonusom
        livingNodes = [:]

        for i in LEVEL!.nodeBlockDict {
          let parent = LEVEL?.level.childNodes[i.key]
            if livingNodes[parent!] == nil {
                livingNodes[parent!] = [:]
            }
            for i in parent!.childNodes {
                livingNodes[parent!]![i] = false
            }
        }

    }
    
    func removeRoad(){
        LEVEL!.level.removeFromParentNode()
    }
    
    func generateRoad(){
        
      let template = source.rootNode.childNode(withName: "roadTemplate", recursively: true)!.clone()
      
      var randomLength = CGFloat(randomCislo(rozsah: 25) * Int(Constants.blockLength)) + CGFloat(25 * Constants.blockLength)
        
        //TUTORIAL
        if user.retrieveActualLevel() < 26 {
            randomLength = tutorialRandomLength()
        }
        
      //testovanie
      //let randomLength: CGFloat = 60
        
        //zakladna viditelna vrstva
       let base = SCNNode(geometry: SCNBox(width: 20, height: 0.1, length: randomLength + startBox, chamferRadius: 0))
        //posuvam o polovicu lebo o polovicu je to uz automaticky posunute
          base.position = SCNVector3(0,-0.1,Float(startBox)/2)
        
          base.name = "base"
          attachStaticBody(base, 0.6, 0.7, 0.1, 0.1, 0.1, 1, 1, 0)
        attachCheckboardDiffuse(material: (base.geometry?.materials.first)!, rgb: UIColor(red: 1, green: 1, blue: 1, alpha: 1), alpha: 0.3,blockCount: Float(randomLength)/Constants.blockLength)
        
        template.addChildNode(base)
        
        //hruba neviditelna vrstva aby sa panak nedostal pod podlahu
      let baseWall = SCNNode(geometry: SCNBox(width: 20, height: 5, length: randomLength, chamferRadius: 0))
          baseWall.position = SCNVector3(0,-2.7,0)
          attachStaticBody(baseWall, 0.6, 0.7, 0.1, 0.1, 0.1, 1, 1, 0)
          attachDiffuseFromNodeToNode(fromNode: template.childNode(withName: "SMRT", recursively: true)!, toNode: baseWall)
        template.addChildNode(baseWall)
        
        template.childNode(withName: "end", recursively: true)!.position.z = Float(-randomLength/2 - 2)

        //fill and save road
        fillRoad(template, Float(randomLength))
        
        let level = Level()
        level.level = template
        level.backgroundColors = randomFarbyPozadie()

        user.saveGeneratedLevel(level: level, nodeBlockDict: nodeBlockDict)
    }

    //CONTINUE FROM THIS!
    func fillRoad(_ template: SCNNode, _ length: Float){

        let fillingLength = length
        
        //inicializujem dictionary
        nodeBlockDict = [:]
        
        //array of structs for not repeating selection
        usedPresets =  []
        
        //reset dangerous cross bonuses counter
        crossBonuses = 0

        //na poslednom mieste uz nechcem predmety
        let blocks = Int(fillingLength/Constants.blockLength)
        
        //minimum odkial spawnujem predmety
        let minimum = length/2
        
        let lastPalette = user.integer(forKey: "colorPalette")
        var colorPalette = lastPalette
        while colorPalette == lastPalette {
            colorPalette = randomCislo(rozsah: 6)
        }
        user.set(colorPalette, forKey: "colorPalette")
        
        //0 relativne fadna
        //1 pekna
        //2 mierne fadna
        //3 v pohode
        //4 mozno moc farebna?
        //5 fadna ale super!

        LEVEL?.level = template
        
        //prechadzam bloky a vyplnam
        var switcher = 0
        for i in 1...blocks-1 {
            let min = SCNVector3(-10,0,minimum - Float(i*Int(Constants.blockLength)))
            let max = SCNVector3(10,0,minimum - Float(i*Int(Constants.blockLength)) + Constants.blockLength)
           
            switcher = fillBlock(template, min, max, colorPalette: colorPalette,blockIndex: i, switcher: switcher)
         
            //generate bonus CIRCLE
            if((i+1) % 5 == 0 && i < blocks-4){
                generateBonus(template, min, max)
            }
            
        }
        
        let finalBonus = templates.rootNode.childNode(withName: "finalBonus", recursively: true)!.clone()
        
        //first gem for first install
        if !user.bool(forKey: "firstGem"){
            
            finalBonus.position = SCNVector3(x:0,y:-10,z: minimum - Float(blocks*Int(Constants.blockLength)) - 80)
            
        } else {
            
            //gem not collected but position generated
            if !user.bool(forKey: "gemCollected"){
                
                let randomX: Float = user.float(forKey: "newGemX")
                let randomY: Float = user.float(forKey: "newGemY")
                finalBonus.position = SCNVector3(x:randomX,y:-10,z: minimum - Float(blocks*Int(Constants.blockLength)) - 80 - randomY)
            
                //gem collected need create another one
            } else {
                
                var randomX: Float = Float(randomCislo(rozsah: 20))
                if random50na50() {
                    randomX = -randomX
                }
                var randomY: Float = Float(randomCislo(rozsah: 15))
                if random50na50() {
                    randomY = -randomY
                }
                
                user.set(randomX, forKey: "newGemX")
                user.set(randomY, forKey: "newGemY")
                finalBonus.position = SCNVector3(x:randomX,y:-10,z: minimum - Float(blocks*Int(Constants.blockLength)) - 80 - randomY)
                user.set(false, forKey: "gemCollected")
            }
            
        }
        
        let rotate = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 2)
        let up = SCNAction.move(by: SCNVector3(x:0,y:3,z:0), duration: 1)
        up.timingMode = .easeOut
        let down = SCNAction.move(by: SCNVector3(x:0,y:-3,z:0), duration: 1)
        down.timingMode = .easeOut
        let sequence = SCNAction.sequence([up,down])
        finalBonus.childNode(withName: "bonusDiamond", recursively: true)!.childNode(withName: "diamond", recursively: true)?.runAction(SCNAction.repeatForever(SCNAction.group([sequence,rotate])))
        template.addChildNode(finalBonus)
        
    }
    
    func generateBonus(_ template: SCNNode,_ min: SCNVector3, _ max: SCNVector3){
        var node: SCNNode!
        
        //TUTORIAL
        if user.retrieveActualLevel() == 1 {
            return
        }
        
        var indexBonusu: Int!
        //TUTORIAL
        let actualLevel = user.retrieveActualLevel()
        if actualLevel < 10 {
           indexBonusu = randomCislo(rozsah: 2) + 1
        } else {
            if actualLevel < 16 {
                if crossBonuses == 2 {
                    indexBonusu = randomCislo(rozsah: 2) + 1
                } else {
                    indexBonusu = randomCislo(rozsah: 3) + 1
                }
            } else if actualLevel > 15 && actualLevel < 25 {
                if crossBonuses == 3 {
                    indexBonusu = randomCislo(rozsah: 2) + 1
                } else {
                    indexBonusu = randomCislo(rozsah: 3) + 1
                }
            } else {
                if crossBonuses == 4 {
                    indexBonusu = randomCislo(rozsah: 2) + 1
                } else {
                    indexBonusu = randomCislo(rozsah: 3) + 1
                }
            }
        }
    
        if indexBonusu == 3 {
            crossBonuses += 1
        }
        
        node = templates.rootNode.childNode(withName: "bonusCircle" + String(indexBonusu), recursively: true)!.clone()
        
        //position x
        if random50na50(){
            node.position.x = min.x + 2 + Float(randomCislo(rozsah: UInt32(Constants.roadWidth - 4)))
        } else {
            node.position.x = max.x - 2 - Float(randomCislo(rozsah: UInt32(Constants.roadWidth - 4)))
        }
        
        let convertedMinX = node.convertPosition(node.boundingBox.min, to: rootNode).x
        let convertedMaxX = node.convertPosition(node.boundingBox.max, to: rootNode).x
        
        if(convertedMinX < min.x + 2){
            node.position.x = node.position.x + ((min.x + 2) - convertedMinX)
        } else if (convertedMaxX > max.x - 2){
            node.position.x = node.position.x - ((convertedMaxX + 2) - max.x)
        }
        
        //position y
        node.position.y = Float(3 + randomCislo(rozsah: 10))
        
        //position z
        node.position.z = Float(min.z)
    
        template.addChildNode(node)
        for i in node.childNodes {
            blinking(i, 0.8)
        }
    }
    
    func fillBlock(_ template: SCNNode, _ minimum: SCNVector3, _ maximum: SCNVector3, colorPalette: Int, blockIndex: Int, switcher: Int) -> Int {
        
        let volba = randomCislo(rozsah: 3)
        
        switch switcher {
        //generating
        case 1:
            
                let pocet = randomCislo(rozsah: 3) + 1
                filling(template, minimum, maximum, pocet, colorPalette)
                return -1
        //random choosing
        case 0:
            
            if volba < 2 {

                let pocet = randomCislo(rozsah: 3) + 1
                filling(template, minimum, maximum, pocet, colorPalette)
                return -1
                
            } else {
                
                fillingWithPresets(template, minimum, colorPalette, blockIndex)
                return 1
            }
        //random choosing
        case -1:
            
            //TUTORIAL, vzdy 2 generovane a 1 blok
            if user.retrieveActualLevel() < 6 {
                let pocet = randomCislo(rozsah: 3) + 1
                filling(template, minimum, maximum, pocet, colorPalette)
                return -2
            }
            
            if volba < 2 {
            
            let pocet = randomCislo(rozsah: 3) + 1
            filling(template, minimum, maximum, pocet, colorPalette)
            return -2
            
        } else {
            
            fillingWithPresets(template, minimum, colorPalette, blockIndex)
            return 1
            }
            
            
        // templating
        case -2:
            
            fillingWithPresets(template, minimum, colorPalette, blockIndex)
            return 1
            
        default: return 0
        }

        }
 
    func fillingWithPresets(_ template: SCNNode, _ minimum: SCNVector3, _ colorPalette: Int, _ blockIndex: Int){
        
        let count = sourceFolders.count
        var folderIndex: Int!
        var nodeIndex: Int!

        //osetrenie aby sa predmety neopakovali
        var repeating = 2
        while repeating >= 1 {
            
            folderIndex = randomCislo(rozsah: UInt32(count))
            nodeIndex = randomCislo(rozsah: UInt32(sourceFolders[folderIndex].childNodes.count))

            repeating = 0
            for i in usedPresets {
                if i.folder == folderIndex && i.block == nodeIndex {
                    repeating += 1
                }
            }
        }
        usedPresets.append(UsedPresets(folder: folderIndex, block: nodeIndex))
        
        let node = sourceFolders[folderIndex].childNodes[nodeIndex].clone()
       
        node.position = SCNVector3(0,0,minimum.z + Constants.blockLength/2)
        for i in node.childNodes {
            //aby sa material skopiroval
            i.geometry = i.geometry?.copy() as? SCNGeometry
            attachDiffuse(material: (i.geometry?.materials.first)!, colorPalette: colorPalette)
            i.name = "target"
            attachDynamicBody(i, 1, 1, 0.9, 0.1, 0.1, 0.1, 4)
            
            i.physicsBody?.categoryBitMask = 1
            i.physicsBody?.collisionBitMask = 1
        }
        
        template.addChildNode(node)
        //ak ma custom block aspon 5 prvkov zaradim do dictionary rodica bloku. nasledne
        //sa v contacte hitnuty node ocekovat ci jeho otec sa nachadza v dict ak ano ide sa riesit
        //efekt vybuchnutia
        if node.childNodes.count > 4 {
            nodeBlockDict[template.childNodes.count-1] = blockIndex
        }
        
    }
    
    func filling(_ template: SCNNode, _ minimum: SCNVector3, _ maximum: SCNVector3, _ count: Int, _ colorPalette: Int){
        
        if count == 1 {
            
            let node = generateNode(template,colorPalette)
            generatePosition(node: node, min: minimum, max: maximum)

            
        } else {
            var nodes = [SCNNode]()

            if percentualnaSanca(percento: 40) {
                //vedla seba
                for _ in 1...count {
                    nodes.append(generateNode(template,colorPalette))
                }
                generatePositions(nodes: nodes, min: minimum, max: maximum)

            } else {
                //na sebe
                if count == 2 {
                    
                    for _ in 1...count {
                        nodes.append(generateNode(template, colorPalette))
                    }
                    generatePosition(node: nodes[0], min: minimum, max: maximum)
                    generateStackPosition(baseNode: nodes[0], newNode: nodes[1])
                   
                    
                    
                //count - 3,4
                } else {
                    
                    for _ in 1...count {
                        nodes.append(generateNode(template, colorPalette))
                    }

                    
                    
                    //jedna kopka
                    if random50na50(){
                        
                        generatePosition(node: nodes[0], min: minimum, max: maximum)
                        for i in 1...nodes.count - 1 {
                            generateStackPosition(baseNode: nodes[i-1], newNode: nodes[i])
                        }
                        
                    //dve kopky
                    } else {
                        
                        generatePositions(nodes: [nodes[0],nodes[2]], min: minimum, max: maximum)
                        generateStackPosition(baseNode: nodes[0], newNode: nodes[1])
                        
                        if count == 4 {
                            generateStackPosition(baseNode: nodes[2], newNode: nodes[3])
                        }
                    }
                }
            }
        }
 
    }
    
    func generateNode(_ template: SCNNode, _ colorPalette: Int) -> SCNNode {
        
        let node = SCNNode(geometry: generateObject())
        node.name = "target"
        attachDynamicBody(node, 1, 1, 0.9, 0.1, 0.1, 0.1, 4)
        attachDiffuse(material: (node.geometry?.materials.first)!, colorPalette: colorPalette)
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.collisionBitMask = 1
        template.addChildNode(node)
        return node
        
    }
    
    
    //vygeneruje nahodny objekt
    func generateObject() -> SCNGeometry {
        
        let random = randomCislo(rozsah: 6)
        
        if random == 0 {

            let box = SCNBox(width: 1 + randomRozmer(rozsah: 3), height: 3 + randomRozmer(rozsah: 3), length: 1 + randomRozmer(rozsah: 4), chamferRadius: 0)
            return box
            
        } else if random == 1 {

            let rozmer = randomRozmer(rozsah: 2)
            return SCNBox(width: 1.5 + rozmer, height: 1.5 + rozmer, length: 1.5 + rozmer, chamferRadius: 0)
            
            
        } else if random == 2 {
            
            let box = SCNBox(width: 1 + randomRozmer(rozsah: 5), height: 3 + randomRozmer(rozsah:3), length: 1 + randomRozmer(rozsah: 2), chamferRadius: 0)
            return box
            
        } else if random == 3 {
            
            let cylinder = SCNCylinder(radius: 1 + randomRozmer(rozsah: 3), height: 1 + randomRozmer(rozsah: 2))
            return cylinder
            
        } else if random == 4 {
            
            let cylinder = SCNCylinder(radius: 1 + randomRozmer(rozsah: 2), height: 1 + randomRozmer(rozsah: 2))
            return cylinder
            
        } else {
            
            let circle = SCNSphere(radius: 1 + randomRozmer(rozsah: 2))
            return circle
            
            
        }
        
        
    }
    
    //ulozi objekt medzi stanovene hrany
    func generatePosition(node: SCNNode, min: SCNVector3, max: SCNVector3){

        //position y
        node.position.y = 0
        node.position.y = node.position.y + (0 - node.boundingBox.min.y)
        
        //position x
        if random50na50(){
            node.position.x = min.x + 2 + Float(randomCislo(rozsah: UInt32(Constants.roadWidth - 4)))
        } else {
            node.position.x = max.x - 2 - Float(randomCislo(rozsah: UInt32(Constants.roadWidth - 4)))
        }
        
        let convertedMinX = node.convertPosition(node.boundingBox.min, to: rootNode).x
        let convertedMaxX = node.convertPosition(node.boundingBox.max, to: rootNode).x
        
        if(convertedMinX < min.x + 2){
            node.position.x = node.position.x + ((min.x + 2) - convertedMinX)
        } else if (convertedMaxX > max.x - 2){
            node.position.x = node.position.x - ((convertedMaxX + 2) - max.x)
        }

        if random50na50() {
            node.position.z = min.z + 2 + Float(randomCislo(rozsah: UInt32(Constants.blockLength - 4)))
        } else {
            node.position.z = max.z - 2 - Float(randomCislo(rozsah: UInt32(Constants.blockLength - 4)))
        }
        let newMin = node.convertPosition(node.boundingBox.min, to: rootNode).z
        let newMax = node.convertPosition(node.boundingBox.max, to: rootNode).z
        
        if(newMin < min.z){
            node.position.z = node.position.z + (newMin - min.z)
            
        } else if (newMax > max.z){
            node.position.z = node.position.z - (newMax - max.z)
        }
        
    }
    
    //postupne vedla seba nauklada vsetky objekty
    func generatePositions(nodes: [SCNNode], min: SCNVector3, max: SCNVector3){
        
        generatePosition(node: nodes[0], min: min, max: max)
        var spaceBetween = space(min: min, max: max)
        
        for i in 1...nodes.count-1 {
   
            spaceBetween = checkLongestSpace(node: nodes[i-1], min: spaceBetween.min, max: spaceBetween.max)
            generatePosition(node: nodes[i], min: spaceBetween.min, max: spaceBetween.max)
            
        }
        
    }
    
    func generateStackPosition(baseNode: SCNNode, newNode: SCNNode){
        
        let cone = baseNode.geometry as? SCNCone
        if cone != nil { 
        }
        
        newNode.position = baseNode.position
        newNode.position.y = newNode.position.y + (baseNode.boundingBox.max.y - newNode.boundingBox.min.y)

    }
    
    //pomocna funkcia ktora porovnava po ulozeni noveho objektu kde zostalo viac priestoru
    func checkLongestSpace(node: SCNNode, min: SCNVector3, max: SCNVector3) -> space {
        
        let leftDistance = node.boundingBox.min.x - min.x
        let rightDistance = max.x - node.boundingBox.max.x
        
        if leftDistance > rightDistance {
          //  print("MIMO + \(node.boundingBox.min.x)")

            return space(min: min, max: SCNVector3(node.boundingBox.min.x,max.y,max.z))
           // return space(min: min, max: node.boundingBox.min)
        } else {
           // print("MIMO + \(node.boundingBox.max.x)")

            return space(min: SCNVector3(node.boundingBox.max.x,min.y,min.z),max: max)
         //   return space(min: node.boundingBox.max, max: max)
        }
        
    }
    
    //pripne material s nahodnou farbou
    func attachDiffuse(material:SCNMaterial, colorPalette: Int){
        
        material.lightingModel = .blinn
        material.diffuse.contents = randomFarbaTarget(colorPalette: colorPalette)
        
    }
    
    func attachSpecificDiffuse(material: SCNMaterial, rgb: UIColor, alpha: CGFloat){
        
        material.lightingModel = .blinn
        material.diffuse.contents = rgb
        material.transparency = alpha
        
        
    }
    
    func attachCheckboardDiffuse(material: SCNMaterial, rgb: UIColor, alpha: CGFloat, blockCount: Float){
        
//        if #available(iOS 10.0, *) {
//            material.lightingModel = .physicallyBased
//            material.metalness.contents = 0.1
//            material.roughness.contents = 0.1
        //} else {
            material.lightingModel = .blinn
       // }
        
        material.transparency = alpha
        
        let layer = CALayer()
        layer.bounds = CGRect(x: 0, y: 0, width: 1500, height: 900)
        layer.backgroundColor = rgb.cgColor
        
        let line = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0,y:450))
        path.addLine(to: CGPoint(x: 1500, y: 450))
        line.path = path.cgPath
        line.lineWidth = 10
        line.strokeColor = UIColor.black.cgColor
        layer.addSublayer(line)
        
        let xes: [CGFloat] = [300,600,900,1200]
        for x in xes {
            
            let line = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x:x,y:0))
            path.addLine(to: CGPoint(x: x, y: 900))
            line.path = path.cgPath
            line.lineWidth = 10
            line.strokeColor = UIColor.black.cgColor
            layer.addSublayer(line)
            
        }
        
        let image = UIImage.image(from: layer)
        
        material.diffuse.contents = image
        material.diffuse.wrapS = SCNWrapMode.repeat
        material.diffuse.wrapT = SCNWrapMode.repeat
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(1, blockCount, 1)

    }
    
    func attachDiffuseFromNodeToNode(fromNode: SCNNode, toNode: SCNNode){
        
        let material = fromNode.geometry?.materials.first

        toNode.geometry?.materials.first?.lightingModel = (material?.lightingModel)!
        toNode.geometry?.materials.first?.diffuse.contents = material?.diffuse.contents
        toNode.geometry?.materials.first?.transparency = (material?.transparency)!

    }
    

}

