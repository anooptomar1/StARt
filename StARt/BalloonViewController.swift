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

    let colorsDictionary = ["red":UIColor.red, "green":UIColor.green, "black":UIColor.black, "brown":UIColor.brown, "blue":UIColor.blue, "cyan":UIColor.cyan, "gray":UIColor.gray, "orange":UIColor.orange]
    
    let colorsStrings = ["red", "green", "blue", "black", "brown", "cyan", "gray", "orange"]
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.brown, UIColor.cyan, UIColor.gray, UIColor.orange]
    var colorToFind:String?
    var pickedColors = [Int](repeating: 0, count:8)

    
    enum BitMaskCategory: Int {
        case bullet = 2
        case target = 3
    }
    
    @IBOutlet weak var colorLabel: UILabel!
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
    
    override func viewDidAppear(_ animated: Bool) {
        addTargets()
        showColorLabel()
    }
    
    
    func showColorLabel() {
        var colorIndex:Int
        repeat{
            colorIndex = Int(randomNumbers(firstNum: 0, secondNum: CGFloat(self.colors.count-1)))
        }while(pickedColors[colorIndex] != 0)
        pickedColors[colorIndex] = 1

        self.colorLabel.text = colorsStrings[colorIndex]
        colorToFind = self.colorLabel.text
        UIView.animate(withDuration: 2, animations: {self.colorLabel.alpha = 1})
    }
    func hideColorLabel() {
        UIView.animate(withDuration: 2, animations: {self.colorLabel.alpha = 0})
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
    
   func addTargets() {
        for colorIndex in 0..<colors.count {
            let balloonNode = self.addBalloon(x: Float(randomNumbers(firstNum: -3, secondNum: 3)), y: Float(randomNumbers(firstNum: 0, secondNum: 1)), z: Float(randomNumbers(firstNum: -2, secondNum: -4)))
            
            let geometry = balloonNode.geometry!
            
            for index in 0..<geometry.materials.count {
                balloonNode.geometry?.materials[index].diffuse.contents = colors[colorIndex]
            }
        }
    }
    
    
    
    func addBalloon(x: Float, y: Float, z: Float) -> SCNNode{
        let balloonScene = SCNScene(named: "Media.scnassets/Balloon.scn")
        let balloonNode = (balloonScene?.rootNode.childNode(withName: "balloon", recursively: false))!
        balloonNode.position = SCNVector3(x,y,z)
        balloonNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: balloonNode, options: nil))
        balloonNode.physicsBody = body
        balloonNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        balloonNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        self.sceneView.scene.rootNode.addChildNode(balloonNode)
        animateBalloon(balloon: balloonNode)
        return balloonNode
    }

    
    func animateBalloon(balloon:SCNNode) {
        let xMovement = randomNumbers(firstNum: -2, secondNum: 2)
        let yMovement = randomNumbers(firstNum: -2, secondNum: 2)
        let animation = SCNAction.sequence([SCNAction.move(by: SCNVector3(xMovement,yMovement,0), duration: 2), SCNAction.move(by: SCNVector3(-xMovement,-yMovement,0), duration: 2)])
        let foreverAnimation = SCNAction.repeatForever(animation)
        balloon.runAction(foreverAnimation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        let confetti = SCNParticleSystem(named: "Media.scnassets/Confetti.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = Target?.geometry
        let confettiNode = SCNNode()
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue &&
            nodeB.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue{
            self.Target = nodeA
            confettiNode.addParticleSystem(confetti!)
            confettiNode.position = contact.contactPoint
            
            if isRightColor(colorLabel: colorToFind!, balloonColor: Target?.geometry?.firstMaterial?.diffuse.contents as! UIColor) {
                self.sceneView.scene.rootNode.addChildNode(confettiNode)
                Target?.removeFromParentNode()
            }
            
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue &&
            nodeA.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue{
            self.Target = nodeB
            confettiNode.addParticleSystem(confetti!)
            confettiNode.position = contact.contactPoint
            
            if isRightColor(colorLabel: colorToFind!, balloonColor: Target?.geometry?.firstMaterial?.diffuse.contents as! UIColor) {
                self.sceneView.scene.rootNode.addChildNode(confettiNode)
                Target?.removeFromParentNode()
            }
            
        }
        
    }
    
    func isRightColor(colorLabel:String, balloonColor:UIColor) -> Bool{
        if colorsDictionary[colorLabel] == balloonColor {
            DispatchQueue.main.async {
                self.showColorLabel()
            }
            return true
        }
        return false
    }
}

