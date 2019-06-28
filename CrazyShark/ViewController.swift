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
    
    @IBOutlet var sceneView: ARSCNView!
    var fishTimer : Timer?
    var gameTimer : Timer?
    var sharkTimer : Timer?
    var fishesArray = [SCNNode]()
    var shark : SCNNode?
    @IBOutlet var sharkScoreText: UILabel!
    @IBOutlet var playerScoreText: UILabel!
    var sharkCreated = false
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // hacemos que el delegado de physicWorld sea la propia view
        sceneView.scene.physicsWorld.contactDelegate = self

        // Show statistics such as fps and node count
        sceneView.showsStatistics = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
            }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        playerScore = 0
        sharkScore = 0
        fishTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (fishTimer) in
//            if self.spriteCounter < 30{
//                self.createFish()
//            }
            if self.fishesArray.count > 1 && self.sharkCreated == false {
                self.shark = self.createShark()
                self.createTarget()
            }
            if self.fishesArray.count < 30 {
                self.createFish()
            }
            
            self.createTarget()
            
        })
        
        gameTimer = Timer.init(fire: Date(), interval: 120, repeats: false, block: { (gameTimer) in
            // falta el codigo para la barrita de progreso

        })


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
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
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var sharkInContact : SCNNode?
        var fishInContact : SCNNode?
        print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue)  ||  (contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue) {
            if contact.nodeA.name! == "shark" || contact.nodeB.name! == "shark" {
                if contact.nodeA.name! == "shark" {
                    sharkInContact = contact.nodeA
                    fishInContact = contact.nodeB
                } else {
                    sharkInContact = contact.nodeB
                    fishInContact = contact.nodeA
                }
                let fishName = fishInContact?.name
                DispatchQueue.main.async {
                    switch fishName {
                    case "shark":
                        return
                    case "firstFish":
                        self.sharkScore += 10
                        self.killFish(fish: fishInContact!, isSharkTheKiller: true)
                    case "secondFish":
                        self.sharkScore += 20
                        self.killFish(fish: fishInContact!, isSharkTheKiller: true)
                    case "thirdFish":
                        self.sharkScore += 30
                        self.killFish(fish: fishInContact!, isSharkTheKiller: true)
                    default:
                        return
                    }
                }
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognice: UIGestureRecognizer) {

        let results = self.sceneView.hitTest(gestureRecognice.location(in: gestureRecognice.view), types: ARHitTestResult.ResultType.featurePoint)
        guard let _ : ARHitTestResult = results.first else {return}
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
                killFish(fish: node, isSharkTheKiller: false)
            case "secondFish":
                playerScore += 20
                killFish(fish: node, isSharkTheKiller: false)
            case "thirdFish":
                playerScore += 30
                killFish(fish: node, isSharkTheKiller: false)
            default:
                return
            }
            
        } else {return}
    }
    
    func createShark() -> SCNNode{
        let minDistance = Float(1)
        let maxDistance = Float(3)
        let plane = SCNPlane(width: 0.6, height: 0.6)
        let shark = createAnyFish(image: UIImage(named: "sharkFirst")!, fishName: "shark", minDistance: minDistance, maxDistance: maxDistance, plane: plane)
        shark.physicsBody?.categoryBitMask = CollisionCategory.sharkCategory.rawValue
        shark.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        shark.physicsBody?.mass = CGFloat(3)
        sceneView.scene.rootNode.addChildNode(shark)
        self.sharkCreated = true
        return shark
    }
    
    func createFish(){
        var fish : SCNNode?
        let fishesProbability = [1, 1, 1, 2, 2, 3]
        let randomFish = fishesProbability[Int(arc4random_uniform(UInt32(fishesProbability.count)))]
        let plane = SCNPlane(width: 0.2, height: 0.2)
        let minDistance = Float(0.9)
        let maxDistance = Float(1)
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
    
    func killFish(fish: SCNNode, isSharkTheKiller: Bool){
        // Creamos, agrupamos y ejecutamos una serie de animaciones
        let scaleOut = SCNAction.scale(to: 2, duration: 0.4)
        let fadeOut = SCNAction.fadeOut(duration: 0.4)
        let remove = SCNAction.removeFromParentNode()
        let groupAction = SCNAction.group([scaleOut, fadeOut])
        let sequenceAction = SCNAction.sequence([groupAction, remove])
        if let fishIndex = self.fishesArray.firstIndex(of: fish) {
            self.fishesArray.remove(at: fishIndex)
        }
        fish.runAction(sequenceAction)
        if isSharkTheKiller {
            self.sharkTarget = nil
        }
    }
    
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
    
    func getUserVector() -> (SCNVector3, SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let playerCamera = SCNMatrix4(frame.camera.transform)
            let playerDirection = SCNVector3(-1 * playerCamera.m31, -1 * playerCamera.m32, -1 * playerCamera.m33)
            let playerPosition = SCNVector3(playerCamera.m41, playerCamera.m42, playerCamera.m43)
            return (playerDirection, playerPosition)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
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
    
    func nodesDistance(nodeA: SCNNode, nodeB: SCNNode) -> (distanceVector: SCNVector3, distance: Float) {
        let distanceVector = SCNVector3(x: -1 * (nodeA.position.x - nodeB.position.x), y: -1 * (nodeA.position.y - nodeB.position.y), z: -1 * (nodeA.position.z
        - nodeB.position.z))
        let distance : Float = sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y + distanceVector.z * distanceVector.z)
        return (distanceVector, distance)
    }
    
    func chaseTarget(node: SCNNode, distance: Float, distanceVector: SCNVector3) {
//        self.shark?.physicsBody?.applyForce(SCNVector3(distanceVector.x * 2, distanceVector.y * 2, distanceVector.z * 2), at: SCNVector3(0.0, 0.0, 0.0), asImpulse: true)
        self.shark?.physicsBody?.applyForce(SCNVector3(distanceVector.x * 0.5, distanceVector.y * 0.5, distanceVector.z * 0.5), at: SCNVector3(0.0, 0.0, 0.0), asImpulse: true)
//        let chaseFish = CABasicAnimation(keyPath: #keyPath(SCNNode.transform))
//        chaseFish.fromValue = self.shark?.transform
//        chaseFish.toValue = node.transform
//        chaseFish.duration = 3
//        self.shark!.addAnimation(chaseFish, forKey: nil)
    }
    
    func createTarget() {
        guard self.shark != nil else {return}
        let (node, distance, distanceVector) = selectTarget()
        chaseTarget(node: node, distance: distance, distanceVector: distanceVector)
        self.sharkTarget = node
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let sharkCategory = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
}
