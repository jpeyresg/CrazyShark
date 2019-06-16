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
    
    let sharkScore = SKLabelNode()
    let sharkScoreIcon = SKSpriteNode()
    var sharkScoreText = 0 {
        didSet{
            self.sharkScore.text = "\(sharkScoreText)"
        }
    }
    let playerScore = SKLabelNode()
    let playerScoreIcon = SKSpriteNode()
    var playerScoreText = 0 {
        didSet{
            self.playerScore.text = "\(playerScoreText)"
        }
    }
//    var timer : Timer?
    var sharkSprite = SKSpriteNode(imageNamed: "shark_first")
    var targetsCreated = 0

    
//    let startTime = Date()
//    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        sharkScore.fontSize = 30
        sharkScore.fontName = "Avenir Next"
        sharkScore.color = .white
        sharkScore.position = CGPoint(x: view.frame.maxX-150, y: view.frame.midY)
        addChild(sharkScore)

        
        playerScore.fontSize = 30
        playerScore.fontName = "Avenir Next"
        playerScore.color = .white
        playerScore.position = CGPoint(x: view.frame.maxX-50, y: view.frame.maxY)
        addChild(playerScore)
        
        sharkScoreText = 0
        playerScoreText = 0
        
        createShark()
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
            let scaleOut = SKAction.scale(to: 2, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let remove = SKAction.removeFromParent()
            let groupAction = SKAction.group([scaleOut, fadeOut])
            let sequenceAction = SKAction.sequence([groupAction, remove])
            
            sprite.run(sequenceAction)

            
        }
        //actualizaremos que hay un pokemon menos con la variable targetCount
    }
    
    func createShark(){
        
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
        translation.columns.3.z = -1.5
        //6. Combinar la rotación del paso 4 con la translación del paso 5
        let finalTransform = simd_mul(rotation, translation)
        //7. Crear un punto de ancla en el punto final determinado en el paso 6
        let anchor = ARAnchor(transform: finalTransform)
        addChild(sharkSprite)
        //8. Añadir esa ancla a la escena

        
    }
    
}
