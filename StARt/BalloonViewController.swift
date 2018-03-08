//
//  BalloonViewController.swift
//  StARt
//
//  Created by Califano Francesco on 08/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit
import ARKit


class BalloonViewController: UIViewController, SCNPhysicsContactDelegate{

    enum BitMaskCategory: Int {
        case bullet = 2
        case target = 3
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power:Float = 10
    var Target:SCNNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(bullet)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2), SCNAction.removeFromParentNode()]))
        
//        let bulletScene = SCNScene(named: "Media.scnassets/Nerf.scn")
//        let bulletNode = bulletScene?.rootNode.childNodes.first
//        bulletNode?.position = position
//        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bulletNode!, options: nil))
//        bulletNode?.physicsBody = body
//        bulletNode?.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
//        body.isAffectedByGravity = false
//        self.sceneView.scene.rootNode.addChildNode(bulletNode!)
        
    }
    
    @IBAction func addTargets(_ sender: Any) {
        self.addBalloon(x: 1, y: 0, z: -7)
        self.addBalloon(x: 0, y: 0, z: -7)
        self.addBalloon(x: -1, y: 0, z: -7)
    }
    
    func addBalloon(x: Float, y: Float, z: Float) {
        let balloonScene = SCNScene(named: "Media.scnassets/Balloon.scn")
        let balloonNode = (balloonScene?.rootNode.childNode(withName: "balloon", recursively: false))!
        balloonNode.position = SCNVector3(x,y,z)
        let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: balloonNode, options: nil))
        balloonNode.physicsBody = body
        balloonNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        balloonNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        self.sceneView.scene.rootNode.addChildNode(balloonNode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeB
        }
        let confetti = SCNParticleSystem(named: "Media.scnassets/Confetti.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = Target?.geometry
        
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        Target?.removeFromParentNode()
    }

}

