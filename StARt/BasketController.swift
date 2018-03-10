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
    case net = 3
    case collider = 4
}

class BasketController: UIViewController,SCNPhysicsContactDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var testo: UILabel!
    
    @IBOutlet weak var mirino: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()
    
    let colorsDictionary = [UIColor.red:"red", UIColor.green:"green", UIColor.black:"black", UIColor.brown:"brown", UIColor.blue:"blue", UIColor.cyan:"cyan", UIColor.gray:"gray", UIColor.orange:"orange"]

    let colorsStrings = ["red", "green", "blue", "black", "brown", "cyan", "gray", "orange"]

    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.brown, UIColor.cyan, UIColor.gray, UIColor.orange]
    
    var indexForColor: Int?
    
    var trigger: SCNNode?
    var existTrigger: Bool = false
    
    var target : SCNNode?
    
    var basketAdded:Bool = false
    
    var power: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.configuration.planeDetection = .horizontal
        
        self.sceneView.session.run(configuration)
        
        self.sceneView.autoenablesDefaultLighting = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var imgArray = [UIImage]()

        imgArray.append(UIImage(named: "Home-1")!)
        imgArray.append(UIImage(named: "Home-2")!)
        
        animateButton(images: imgArray, button: homeButton)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        
        guard let pointOfView = sceneView.pointOfView else {return}
        
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        if self.basketAdded == false{
            
            addBasket(x: 0, y: 0, z: -2.5)
            
            self.basketAdded = true;
        }
        
        else{
            
            if !self.existTrigger{
                createTrigger()
                self.existTrigger = true
            }
            
            self.removeOtherBall()
            
            self.power = 10
            
            let ball = SCNNode(geometry: SCNSphere(radius: 0.2))
            
            ball.name = "ball"
            
            self.indexForColor = Int(randomNumbers(from: 0, to: CGFloat(colors.count-1)))
            
            let colorToUse = colors[indexForColor!]
            
            ball.geometry?.firstMaterial?.diffuse.contents = colorToUse
            
            ball.position = position
            
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
            
            ball.physicsBody = body
            
            ball.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
            
            ball.physicsBody?.categoryBitMask = BitMaskCategory.ball.rawValue
            ball.physicsBody?.collisionBitMask = BitMaskCategory.net.rawValue | BitMaskCategory.collider.rawValue
            ball.physicsBody?.contactTestBitMask = BitMaskCategory.collider.rawValue
            
            
            
            self.sceneView.scene.rootNode.addChildNode(ball)
            
        }
        
    }
    
    func addBasket(x: Float, y: Float, z: Float){
        
        let basketScene = SCNScene(named: "Media.scnassets/BasketField.scn")
        
        let basketNode = (basketScene?.rootNode.childNode(withName: "Basket", recursively: false))!
        
        let collider = (basketScene?.rootNode.childNode(withName: "collider", recursively: false))!
        
        basketNode.position = SCNVector3(x,y,z)
        
        basketNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketNode, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        basketNode.physicsBody?.restitution = 0.2
        
        collider.position = SCNVector3(x,y+1.5,z-3.1)
        
        collider.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: collider, options: nil))
        
        basketNode.physicsBody?.categoryBitMask = BitMaskCategory.net.rawValue
        basketNode.physicsBody?.collisionBitMask = BitMaskCategory.ball.rawValue
        
        collider.physicsBody?.categoryBitMask = BitMaskCategory.collider.rawValue
//        collider.physicsBody?.collisionBitMask = BitMaskCategory.ball.rawValue
        collider.physicsBody?.contactTestBitMask = BitMaskCategory.ball.rawValue
        
        trigger = collider.clone()
        
        self.sceneView.scene.rootNode.addChildNode(basketNode)
        
        
    }
    
    func loadAimShape(){
        
    }
    
    func createTrigger(){
        self.sceneView.scene.rootNode.addChildNode(trigger!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeOtherBall(){
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in
            if node.name == "Basketball"{
                node.removeFromParentNode()
            }
        }
    }
    
    func randomNumbers(from firstNum: CGFloat, to secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        var color : UIColor?
        
        if nodeA.name == "collider"{
            
            self.target = nodeA
            
        } else if nodeB.name == "collider" {
            
            self.target = nodeB
        }
        
        if nodeA.name == "ball"{
            
            color = nodeA.geometry?.firstMaterial?.diffuse.contents as? UIColor
            
        } else if nodeB.name == "ball" {
            
            color = nodeB.geometry?.firstMaterial?.diffuse.contents as? UIColor
        }
        
        DispatchQueue.main.async(){
            
            if self.testo.isHidden{
                self.testo.isHidden = false
            }
            
            self.testo.text = self.colorsDictionary[color!]?.description
            self.testo.textColor = color
        }
        
        target?.removeFromParentNode()
        self.existTrigger = false
        
        
        
    }
    

}


