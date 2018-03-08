//
//  BasketController.swift
//  iLeARn
//
//  Created by Menichino Alfonso on 06/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit
import ARKit

enum BitMaskCategory: Int {
    case ball = 2
    case target = 3
}

class BasketController: UIViewController, ARSCNViewDelegate,SCNPhysicsContactDelegate {

    
    @IBOutlet weak var score: UILabel!
    var scorePoint: Int = 0
    
    @IBOutlet weak var planeDetected: UILabel!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var Target: SCNNode?
    
    
    
    var basketAdded:Bool {
        return self.sceneView.scene.rootNode.childNode(withName: "Basket", recursively: false) != nil
        
    }
    
    var power: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.basketAdded == true{
            guard let pointOfView = self.sceneView.pointOfView else {return}
            self.removeOtherBall()
            self.power = 10
            let transform = pointOfView.transform
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            
            let position = location + orientation
            
            //palla
            let ball = SCNNode(geometry: SCNSphere(radius: 0.1))
            ball.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            ball.position = position
            
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball, options: nil))
            
            ball.physicsBody = body
            
            
            ball.name = "Basketball"
            
            body.restitution = 0.2
            
            ball.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
            
            ball.physicsBody?.categoryBitMask = BitMaskCategory.ball.rawValue
            ball.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
            
            self.sceneView.scene.rootNode.addChildNode(ball)
        }
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        
        if !hitTestResult.isEmpty{
            self.addBasket(hitTestResult: hitTestResult.first!)
        }
    }
    
    func addBasket(hitTestResult: ARHitTestResult){
        
        let basketScene = SCNScene(named: "Palla.scnassets/Basketball.scn")
        
        let basketNode = basketScene?.rootNode.childNode(withName: "Basket", recursively: false)
        
        let collider = basketNode?.childNode(withName: "collider", recursively: false)
        
        collider?.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        collider?.physicsBody?.contactTestBitMask = BitMaskCategory.ball.rawValue
        
        let positionOfPlane = hitTestResult.worldTransform.columns.3
        let xPosition = positionOfPlane.x
        let yPosition = positionOfPlane.y
        let zPosition = positionOfPlane.z
        
        basketNode?.position = SCNVector3(xPosition,yPosition,zPosition)
        
        basketNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        self.sceneView.scene.rootNode.addChildNode(basketNode!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARPlaneAnchor else {return}
        
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.planeDetected.isHidden = true
        }
        
    }
    
    func removeOtherBall(){
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in
            if node.name == "Basketball"{
                node.removeFromParentNode()
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("contatto")
        
        /*let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeB
        }
        
        
        
        let confetti = SCNParticleSystem(named: "Media.scnassets/Fire.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = Target?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        Target?.removeFromParentNode()*/
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z )
    
}
