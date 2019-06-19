//
//  Scene.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 10/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    var sharkGame: SharkGameProtocol?

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
                return
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
    
    func createSprite(){
        
        if spritesCreated == 46 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        
        // Switch que definirá el aranchor.name o nombre del ancla que vendrá de un struct
        guard let sceneView = self.view as? ARSKView else {return}
        
        // 1. Crear un generador de números aleatorios
        let random = GKRandomSource.sharedRandom()
        //2. Crear una matriz de rotación aleatoria en X
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 1, 0, 0))
        //3. Crear una matriz de ratación aleatoria en Y
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 0, 1, 0))
        //4. Combinar las dos roataciones con un producto de matrices
        let rotation = simd_mul(rotateX, rotateY)
        //5. Crear una translación de 1.5 metros en la dirección de la pantalla
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -2
        //6. Combinar la rotación del paso 4 con la translación del paso 5
        let finalTransform = simd_mul(rotation, translation)
        //7. Crear un punto de ancla en el punto final determinado en el paso 6
//        let anchor = ARAnchor(transform: finalTransform)
        switch spritesCreated {
        case 0:
            let anchor = ARAnchor(name: "shark", transform: finalTransform)
            sceneView.session.add(anchor: anchor)
        case 1...31:
            let anchor = ARAnchor(name: "firstFish", transform: finalTransform)
            sceneView.session.add(anchor: anchor)
        case 31...41:
            let anchor = ARAnchor(name: "secondFish", transform: finalTransform)
            sceneView.session.add(anchor: anchor)
        case 41...46:
            let anchor = ARAnchor(name: "thirdFish", transform: finalTransform)
            sceneView.session.add(anchor: anchor)
        default:
            let anchor = ARAnchor(name: "firstFish", transform: finalTransform)
            sceneView.session.add(anchor: anchor)
        }
        spritesCreated += 1
    }
    
}

protocol SharkGameProtocol {
    func sharkScoreDidChange(score: Int)
    func playerScoreDidChange(score: Int)
}
