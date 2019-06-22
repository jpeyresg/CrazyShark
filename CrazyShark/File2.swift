//
//  File2.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 22/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import Foundation
import SpriteKit
import ARKit
import GameplayKit

class File2: SKScene {
    
    var sharkGame: SharkGameProtocol?
    var sharkSprite : SKNode?
    var targetCreated = false
    var fishTarget : SKNode?
    var fishes = [SCNNode]()
    var sharkScoreText = 0 {
        didSet{
            self.sharkGame?.sharkScoreDidChange(score: self.sharkScoreText)
        }
    }
    
    var playerScoreText = 0 {
        didSet{
            self.sharkGame?.playerScoreDidChange(score: self.playerScoreText)
        }
    }
    var timer : Timer?
    enum fishType {
        case shark, firstFish, secondFish, thirdFish
    }
    var spritesCreated = 0
    
    //    let startTime = Date()
    //    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        
        
        sharkScoreText = 0
        playerScoreText = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.createSprite()
            
        })
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //localizar el primer toque del conjunto de toques
        //mirar si el toque cae dentro de nuestra vista de AR
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        //buscaremos todos los nodos que han sido tocados por ese toque de usuario
        let hit = nodes(at: location)
        //cogeremos el primer sprite del array que nos devuelve el método anterior (si lo hay) y animaremos ese pokemon hasta hacerlo desaparecer
        if let sprite = hit.first{
            guard let spriteName = sprite.name else{return}
            
            switch spriteName {
            case "shark":
                moveShark(node: sprite, destiny: (x: CGFloat(2), y: CGFloat(2), z: CGFloat(0)))
            case "firstFish":
                playerScoreText += 10
                killFish(sprite: sprite)
            case "secondFish":
                playerScoreText += 20
                killFish(sprite: sprite)
            case "thirdFish":
                playerScoreText += 30
                killFish(sprite: sprite)
            default:
                return
            }
            
        }
        //actualizaremos que hay un pokemon menos con la variable targetCount
    }
    
    func killFish(sprite: SKNode){
        let scaleOut = SKAction.scale(to: 2, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        let groupAction = SKAction.group([scaleOut, fadeOut])
        let sequenceAction = SKAction.sequence([groupAction, remove])
        sprite.run(sequenceAction)
    }
    
    func createSprite(fishType: fishType){
        
        if spritesCreated == 46 {
            timer?.invalidate()
            timer = nil
            return
        }
        var fish : SCNNode?
        // Switch que definirá el aranchor.name o nombre del ancla que vendrá de un struct
        guard let sceneView = self.view as? ARSCNView else {return}
        
        // 1. Crear un generador de números aleatorios
        let random = GKRandomSource.sharedRandom()
        //2. Crear una matriz de rotación aleatoria en X
        let rotateX = SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 1, 0, 0)
        //3. Crear una matriz de ratación aleatoria en Y
        let rotateY = SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 0, 1, 0)
        //4. Combinar las dos roataciones con un producto de matrices
        let rotation = SCNMatrix4Mult(rotateX, rotateY)
        //5. Crear una translación de 1.5 metros en la dirección de la pantalla
        var translation = SCNMatrix4Identity
        translation.m43 = -2
        //6. Combinar la rotación del paso 4 con la translación del paso 5
        let finalTransform = SCNMatrix4Mult(rotation, translation)
        //7. Crear un punto de ancla en el punto final determinado en el paso 6
        //        let anchor = ARAnchor(transform: finalTransform)
        switch fishType {
        case .shark:
            fish = createAnyFish(image: UIImage(named: "sharkFirst")!, fishName: "shark")
            
        case .firstFish:
            fish = createAnyFish(image: UIImage(named: "firstFish")!, fishName: "firstFish")
            
        case .secondFish:
            fish = createAnyFish(image: UIImage(named: "secondFish")!, fishName: "secondFish")
            
        case .thirdFish:
            fish = createAnyFish(image: UIImage(named: "thirdFish")!, fishName: "thirdFish")
            
        }
        fish!.transform = finalTransform
        sceneView.scene.rootNode.addChildNode(fish!)
        spritesCreated += 1
    }
    
    func createAnyFish(image: UIImage, fishName: String) -> SCNNode {
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        node.name = fishName
        return node
    }
    
    func moveShark(node: SKNode, target: SKNode){
        
    }
    
    func moveShark(node: SKNode, destiny: (x: CGFloat, y: CGFloat, z: CGFloat)){
        let movement = SKAction.move(by: CGVector(dx: destiny.x, dy: destiny.y), duration: 2)
        node.run(movement)
        
    }
    
    func createTarget(sharkNode:SKNode) -> SKNode{
        return sharkNode
    }
    
}

protocol SharkGameProtocol {
    func sharkScoreDidChange(score: Int)
    func playerScoreDidChange(score: Int)
}
