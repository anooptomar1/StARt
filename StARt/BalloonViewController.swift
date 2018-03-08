//
//  BalloonViewController.swift
//  StARt
//
//  Created by Califano Francesco on 08/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit
import ARKit

class BalloonViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(transform.m31, transform.m32, transform.m33)
    }
    
    @IBAction func addTargets(_ sender: Any) {
        self.addBalloon(x: 0.45, y: 0, z: -2)
        self.addBalloon(x: 0, y: 0, z: -2)
        self.addBalloon(x: -0.45, y: 0, z: -2)
    }
    
    func addBalloon(x: Float, y: Float, z: Float) {
        let balloonScene = SCNScene(named: "Media.scnassets/Balloon.scn")
        let balloonNode = balloonScene?.rootNode.childNodes.first
        balloonNode?.position = SCNVector3(x,y,z)
        self.sceneView.scene.rootNode.addChildNode(balloonNode!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
