//
//  File.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 15/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import Foundation
//
//  Scene.swift
//  PokemonAR
//
//  Created by Juan Garrido Peyres on 23/04/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scenes: SKScene {
    
    let remainingLabel = SKLabelNode()
    var timer : Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        // el método didset se ejecuta cada vez que cambia el valor de la variable targetCount
        didSet{
            self.remainingLabel.text = "Faltan: \(targetCount)"
        }
    }
    
    let startTime = Date()
    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        //Configuración del head's up display HUD
        remainingLabel.fontSize = 30
        remainingLabel.fontName = "Avenir Next"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY-50)
        addChild(remainingLabel)
        
        targetCount = 0
        
        //Creación del timer que crea enemigos
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            self.createTarget()
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
            let scaleOut = SKAction.scale(to: 2, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let remove = SKAction.removeFromParent()
            let groupAction = SKAction.group([scaleOut, fadeOut, deathSound])
            let sequenceAction = SKAction.sequence([groupAction, remove])
            
            sprite.run(sequenceAction)
            targetCount -= 1
            
            if targetsCreated == 25 && targetCount == 0 {
                gameOver()
            }
        }
        //actualizaremos que hay un pokemon menos con la variable targetCount
    }
    
    func createTarget(){
        
        if targetsCreated == 25 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
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
        //8. Añadir esa ancla a la escena
        sceneView.session.add(anchor: anchor)
    }
    
    func gameOver() {
        //Ocultar la remainingLabel
        remainingLabel.removeFromParent()
        //Crear una nueva imagen con la foto de game over
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        addChild(gameOver)
        //Calcular cuanto tiempo le ha llevado al usuario cazar a todos los pokemon
        let timeTaken = Date().timeIntervalSince(startTime)
        //Mostrar ese tiempo que le ha llevado en pantalla en una etiqueta nueva
        let timeTakenLabel = SKLabelNode(text: "Te ha llevado: \(Int(timeTaken)) segundos")
        timeTakenLabel.fontSize = 40
        timeTakenLabel.color = .white
        timeTakenLabel.position = CGPoint(x: view!.frame.maxX - 50, y: -view!.frame.midY + 50)
        addChild(timeTakenLabel)
    }
    
}
