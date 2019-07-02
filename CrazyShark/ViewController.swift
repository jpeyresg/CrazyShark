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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    // MARK: - Variables
    
    @IBOutlet var sceneView: ARSCNView!
    var gameTimer : Timer?
    var progressBarTimer: Timer?
    var gameSeconds = 60
    var fishesArray = [SCNNode]()
    var shark : SCNNode?
    @IBOutlet var sharkScoreText: UILabel!
    @IBOutlet var playerScoreText: UILabel!
    var fishBeingKilled : SCNNode?
    var sharkTarget : SCNNode? {
        didSet{
            if self.sharkTarget == nil {
                self.createTarget()
            }
        }
    }
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
    
    // MARK: - Buttons
    
    @IBOutlet weak var menuButton: UIButton!
    
    // Esta función nos devuelve al viewcontroller que tiene el menú principal
    @IBAction func menuButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.showsStatistics = false
        
        menuButton.layer.cornerRadius = menuButton.bounds.height / 2
        menuButton.backgroundColor = UIColor(red: (105/255), green: (183/255), blue: (230/255), alpha: 1)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        for _ in 0...19 {
            self.createFish()
        }
        shark = self.createShark()
        playerScore = 0
        sharkScore = 0
        createTarget()
        progressBar.progress = 1.0
        runGameTimer()
        playBackgroundMusic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - SCNPhysicsContactDelegate
    
    // Con esta función del delegado manejamos las colisiones entre los peces y el tiburón
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var fishInContact : SCNNode?
        print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue)  ||  (contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue) {
            if contact.nodeA.name! == "shark" || contact.nodeB.name! == "shark" {
                if contact.nodeA.name! == "shark" {
                    fishInContact = contact.nodeB
                } else {
                    fishInContact = contact.nodeA
                }
                let fishName = fishInContact?.name
                if self.fishBeingKilled != nil {return}
                self.fishBeingKilled = fishInContact
                DispatchQueue.main.async {
                    switch fishName {
                    case "shark":
                        return
                    case "firstFish":
                        self.sharkScore += 10
                        self.killFish(fish: fishInContact!)
                        self.playSound(sound: "sharkBite", format: "mp3")
                    case "secondFish":
                        self.sharkScore += 20
                        self.killFish(fish: fishInContact!)
                        self.playSound(sound: "sharkBite", format: "mp3")
                    case "thirdFish":
                        self.sharkScore += 30
                        self.killFish(fish: fishInContact!)
                        self.playSound(sound: "sharkBite", format: "mp3")
                    default:
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Gesture recognizer
    
    // Esta función se encarga de manejar los toques en la pantalla
    @objc func handleTap(_ gestureRecognice: UIGestureRecognizer) {

        let _ = self.sceneView.hitTest(gestureRecognice.location(in: gestureRecognice.view), types: ARHitTestResult.ResultType.featurePoint)
        let tappedNode = self.sceneView.hitTest(gestureRecognice.location(in: gestureRecognice.view), options: nil)
        if !tappedNode.isEmpty {
            let node = tappedNode[0].node
            print("Has todaco a \(String(describing: node.name))")
            let fishName = node.name
            switch fishName {
            case "shark":
                return
            case "firstFish":
                playerScore += 10
                killFish(fish: node)
                self.playSound(sound: "fishCatched", format: "mp3")
            case "secondFish":
                playerScore += 20
                killFish(fish: node)
                self.playSound(sound: "fishCatched", format: "mp3")
            case "thirdFish":
                playerScore += 30
                killFish(fish: node)
                self.playSound(sound: "fishCatched", format: "mp3")
            case "gameOver":
                self.dismiss(animated: true, completion: nil)
            default:
                return
            }
            
        } else {return}
    }
    
    // MARK: - Creating game creatures
    
    // Esta función parametriza al tiburón y le pasa los parámetros a la función
    // createAnyFish para que cree el tiburón con esos parámetros
    func createShark() -> SCNNode{
        let minDistance = Float(1)
        let maxDistance = Float(3)
        let plane = SCNPlane(width: 0.6, height: 0.6)
        let shark = createAnyFish(image: UIImage(named: "sharkRight")!, fishName: "shark", minDistance: minDistance, maxDistance: maxDistance, plane: plane)
        shark.physicsBody?.categoryBitMask = CollisionCategory.sharkCategory.rawValue
        shark.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        shark.physicsBody?.mass = CGFloat(3)
        sceneView.scene.rootNode.addChildNode(shark)
        return shark
    }
    
    // Esta función parametriza los peces de manera aleatoria y le pasa los parámetros a la función
    // createAnyFish para que cree el pez con esos parámetros
    func createFish(){
        var fish : SCNNode?
        let fishesProbability = [1, 1, 1, 2, 2, 3]
        let randomFish = fishesProbability[Int(arc4random_uniform(UInt32(fishesProbability.count)))]
        let plane = SCNPlane(width: 0.2, height: 0.2)
        let minDistance = Float(0.9)
        let maxDistance = Float(3)
        switch randomFish {
        case 1:
            fish = createAnyFish(image: UIImage(named: "firstFish")!, fishName: "firstFish", minDistance: minDistance, maxDistance: maxDistance, plane: plane)
        case 2:
            fish = createAnyFish(image: UIImage(named: "secondFish")!, fishName: "secondFish", minDistance: minDistance, maxDistance: maxDistance, plane: plane)
        case 3:
            fish = createAnyFish(image: UIImage(named: "thirdFish")!, fishName: "thirdFish", minDistance: minDistance, maxDistance: maxDistance, plane: plane)
        default:
            return
        }
        
        fish!.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
        fish!.physicsBody?.contactTestBitMask = CollisionCategory.sharkCategory.rawValue
        fish!.physicsBody?.mass = CGFloat(1)
        sceneView.scene.rootNode.addChildNode(fish!)
        self.fishesArray.append(fish!)
        self.moveFishes(fish: fish!)
    }
    
    
    // Esta función crea un pez con los parámetros dados y lo devuelve
    func createAnyFish(image: UIImage, fishName: String, minDistance: Float, maxDistance: Float, plane: SCNPlane) -> SCNNode {
        
        plane.firstMaterial?.diffuse.contents = image
        let fish = SCNNode(geometry: plane)
        fish.constraints = [SCNBillboardConstraint()]
        fish.name = fishName
        fish.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        fish.physicsBody?.isAffectedByGravity = false
        let (_, position) = self.getUserVector()
        fish.position = SCNVector3(position.x + Float.random(in: (-1 * maxDistance)...maxDistance), position.y + Float.random(in: (-1 * maxDistance)...maxDistance), position.z - 2)

        return fish
    }
    
    // MARK: - Managing game creatures
    
    // Esta función se encarga de eliminar el pez que le pasan por parámetro de manera animada
    func killFish(fish: SCNNode){
        if let fishIndex = self.fishesArray.firstIndex(of: fish) {
            self.fishesArray.remove(at: fishIndex)
        }
        if fish == self.sharkTarget {
            self.sharkTarget = nil
            self.fishBeingKilled = nil
        } else {
            self.fishBeingKilled = nil
        }
        let scaleOut = SCNAction.scale(to: 2, duration: 0.4)
        let fadeOut = SCNAction.fadeOut(duration: 0.4)
        let remove = SCNAction.removeFromParentNode()
        let groupAction = SCNAction.group([scaleOut, fadeOut])
        let sequenceAction = SCNAction.sequence([groupAction, remove])
        fish.runAction(sequenceAction)
        
    }
    
    // Esta función añade un movimiento similar al baiben del agua, al pez que se le pasa por parametro
    func moveFishes(fish: SCNNode) {
        
        let moveUp = CABasicAnimation(keyPath: #keyPath(SCNNode.transform))
        moveUp.fromValue = fish.transform
        var movement = fish.transform
        movement.m42 += 0.1
        moveUp.toValue = movement
        moveUp.duration = 1
        moveUp.autoreverses = true
        moveUp.repeatCount = .infinity
        fish.addAnimation(moveUp, forKey: nil)
    }
    
    // Esta función devuelve dos vectores referentes al jugador, el de posición y el de dirección
    func getUserVector() -> (SCNVector3, SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let playerCamera = SCNMatrix4(frame.camera.transform)
            let playerDirection = SCNVector3(-1 * playerCamera.m31, -1 * playerCamera.m32, -1 * playerCamera.m33)
            let playerPosition = SCNVector3(playerCamera.m41, playerCamera.m42, playerCamera.m43)
            return (playerDirection, playerPosition)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    // Esta función devuelve el nodo del pez más cercano al tiburón, su distancia y su dirección
    func selectTarget() -> (node: SCNNode, distance: Float, distanceVector: SCNVector3) {
        var distanceArray = [Float]()
        var vectorArray = [SCNVector3]()
        for node in self.fishesArray {
            let (distanceVector, distance) = self.nodesDistance(nodeA: self.shark!, nodeB: node)
            distanceArray.append(distance)
            vectorArray.append(distanceVector)
        }
        let targetDistance = distanceArray.min()
        let targetNode = self.fishesArray[distanceArray.firstIndex(of: targetDistance!)!]
        let targetVector = vectorArray[distanceArray.firstIndex(of: targetDistance!)!]
        return (targetNode, targetDistance!, targetVector)
    }
    
    // Esta función devuelve la distancia y la dirección del nodo A al nodo B
    func nodesDistance(nodeA: SCNNode, nodeB: SCNNode) -> (distanceVector: SCNVector3, distance: Float) {
        let distanceVector = SCNVector3(x: -1 * (nodeA.position.x - nodeB.position.x), y: -1 * (nodeA.position.y - nodeB.position.y), z: -1 * (nodeA.position.z
        - nodeB.position.z))
        let distance : Float = sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y + distanceVector.z * distanceVector.z)
        return (distanceVector, distance)
    }
    
    // Esta función pone en movimiento al tiburón en busca del pez que se le pasa por parámetros
    // junto con la distancia y la dirección de dicho pez
    func chaseTarget(node: SCNNode, distance: Float, distanceVector: SCNVector3) {
        let speed : Float = 0.1
        let timeToTarget = Double(distance / speed)
        let chaseFish = SCNAction.move(by: distanceVector, duration: timeToTarget)
        if distanceVector.x < 0 {
            SCNTransaction.begin()
            let materials = self.shark!.geometry?.materials
            let material = materials![0]
            material.diffuse.contents = UIImage(named: "sharkLeft")
            SCNTransaction.commit()
        } else {
            SCNTransaction.begin()
            let materials = self.shark!.geometry?.materials
            let material = materials![0]
            material.diffuse.contents = UIImage(named: "sharkRight")
            SCNTransaction.commit()
        }
        self.shark?.runAction(chaseFish)
    }
    
    // Esta función se encarga de seleccionar el pez más cercano al tiburón y perseguirlo
    func createTarget() {
        guard self.shark != nil else {return}
        let (node, distance, distanceVector) = selectTarget()
        chaseTarget(node: node, distance: distance, distanceVector: distanceVector)
        self.sharkTarget = node
    }
    
    // MARK: - Game timers
    
    // Esta función dispara los dos timers del juego
    func runGameTimer() {
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateGameTimer), userInfo: nil, repeats: true)
        self.progressBarTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        
    }
    
    // Esta función actualiza los segundos de juego, en caso de llegar a cero termina el juego
    // si la cantidad de peces disminuye por debajo de 10 crea 5 más y cada dos segundos actualiza
    // el target del tiburón
    @objc func updateGameTimer() {
        if gameSeconds == 0 {
            gameTimer?.invalidate()
            gameOver()
        } else {
            gameSeconds -= 1

            if self.fishesArray.count < 10 {
                for _ in 0...5 {
                    self.createFish()
                }
            }
            if (gameSeconds % 2) == 0{
                createTarget()
            }
        }
    }
    
    // MARK: - Finishing the game
    
    // Esta función termina el juego, mostrando el cartel de victoria si así ha sido, grabando la puntuación.
    // En caso de derrota muestra el cartel de derrota
    func gameOver() {
        self.shark?.removeFromParentNode()
        for i in 0 ..< fishesArray.count {
            fishesArray[i].removeFromParentNode()
        }
        fishesArray.removeAll()

        let gameOverPlane = SCNPlane(width: 1, height: 2)
        
        if playerScore > sharkScore {
            let defaults = UserDefaults.standard
            defaults.set(playerScore, forKey: "score")
            gameOverPlane.firstMaterial?.diffuse.contents = UIImage(named: "youWinFrame")
            playSound(sound: "winGameSound", format: "mp3")
        } else {
            gameOverPlane.firstMaterial?.diffuse.contents = UIImage(named: "youLoseFrame")
            playSound(sound: "lostGameSound", format: "mp3")
        }
        
        let gameOverFrame = SCNNode(geometry: gameOverPlane)
        gameOverFrame.name = "gameOver"
        gameOverFrame.position = SCNVector3(0, 0, -2)
        sceneView.pointOfView?.addChildNode(gameOverFrame)
    }
    
    // MARK: - Time progress bar
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    // Esta función actualiza la barra del tiempo
    @objc func updateProgressBar(){
        progressBar.progress -= 0.001667
        progressBar.setProgress(progressBar.progress, animated: true)
    }
    
    // MARK: - sounds
    
    var player: AVAudioPlayer?
    
    // Esta función reproduce el archivo de sonido que se le pasa por parámetros junto con su extensión
    func playSound(sound : String, format: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: format) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Esta función crea un nodo en la escena que reproduce la música de fondo
    func playBackgroundMusic(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "crazySharkMusic.mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        
        audioNode.addAudioPlayer(audioPlayer)
        
        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
}

// MARK: - Collision Categories

// Estructura para clasificar y manejar las colisiones
struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let sharkCategory = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
}
