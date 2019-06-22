//
//  ViewController.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 10/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GameplayKit

class ViewController: UIViewController, ARSCNViewDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    var fishTimer : Timer?
    var gameTimer : Timer?
    var sharkTimer : Timer?
    var spriteCounter = 0
    var sharkCreated = false
    @IBOutlet var sharkScoreText: UILabel!
    @IBOutlet var playerScoreText: UILabel!
    var sharkScore = 0 {
        didSet{
            self.sharkScoreText.text = "\(self.sharkScore)"
        }
    }
    var playerScore = 0 {
        didSet{
            self.playerScoreText.text = "\(self.playerScore)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and node count
        sceneView.showsStatistics = false
            }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        playerScore = 0
        sharkScore = 0
        fishTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (gameTimer) in
            if self.spriteCounter < 30{
                self.createFish()
            }
        })
        
        gameTimer = Timer.init(fire: Date(), interval: 120, repeats: false, block: { (gameTimer) in
            // codigo para la barrita de progreso
        })

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //localizar el primer toque del conjunto de toques
        //mirar si el toque cae dentro de nuestra vista
        guard let sceneView = self.view as? ARSCNView else { return }
        guard let touch = touches.first else {return}
        let location = touch.location(in: sceneView)
        
        //buscaremos todos los nodos que han sido tocados por ese toque de usuario
        let hit = sceneView.hitTest(location, options: nil)
        
        //cogeremos el primer sprite del array que nos devuelve el método anterior (si lo hay) y haremos las acciones pertinentes según el nombre del nodo
        guard let sprite = hit.first?.node else {return}
        let spriteName = sprite.name
        switch spriteName {
        case "shark":
            return
        case "firstFish":
            playerScore += 10
            killFish(sprite: sprite)
        case "secondFish":
            playerScore += 20
            killFish(sprite: sprite)
        case "thirdFish":
            playerScore += 30
            killFish(sprite: sprite)
        default:
            return
        }
        //actualizaremos que hay un pescado menos
        self.spriteCounter -= 1
    }
    
    func createShark(){
        let shark = createAnyFish(image: UIImage(named: "sharkFirst")!, fishName: "shark")
        sceneView.scene.rootNode.addChildNode(shark)
        self.sharkCreated = true
    }
    
    func createFish(){
        var fish : SCNNode?
        let fishesProbability = [1, 1, 1, 2, 2, 3]
        let randomFish = fishesProbability[Int(arc4random_uniform(UInt32(fishesProbability.count)))]
        switch randomFish {
        case 1:
            fish = createAnyFish(image: UIImage(named: "firstFish")!, fishName: "firstFish")
        case 2:
            fish = createAnyFish(image: UIImage(named: "secondFish")!, fishName: "secondFish")
        case 3:
            fish = createAnyFish(image: UIImage(named: "thirdFish")!, fishName: "thirdFish")
        default:
            return
        }
        sceneView.scene.rootNode.addChildNode(fish!)
        spriteCounter += 1
    }
    
    func createAnyFish(image: UIImage, fishName: String) -> SCNNode {
        
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

        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        node.name = fishName
        node.transform = finalTransform
        return node
    }
    
    func killFish(sprite: SCNNode){
        // Creamos, agrupamos y ejecutamos una serie de animaciones
        let scaleOut = SCNAction.scale(to: 2, duration: 0.4)
        let fadeOut = SCNAction.fadeOut(duration: 0.4)
        let remove = SCNAction.removeFromParentNode()
        let groupAction = SCNAction.group([scaleOut, fadeOut])
        let sequenceAction = SCNAction.sequence([groupAction, remove])
        sprite.runAction(sequenceAction)
    }
    
}
