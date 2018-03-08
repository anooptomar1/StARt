//
//  ViewController.swift
//  EasyLearn
//
//  Created by Califano Francesco on 06/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//
import UIKit
import ARKit
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var player: AVAudioPlayer?

    @IBOutlet weak var tapHintImageView: UIImageView!
    @IBOutlet weak var basketballCollectionView: UICollectionView!
    @IBOutlet weak var golfCollectionView: UICollectionView!
    @IBOutlet weak var nerfCollectionView: UICollectionView!
    
    //Arrays and images for  collection views
    let basketballImage = UIImage(named: "Basketball")
    let golfBallImage = UIImage(named: "GolfBall")
    let nerfImage = UIImage(named: "NerfDart")
    var basketballImages = [UIImage]()
    var golfImages = [UIImage]()
    var nerfImages = [UIImage]()
    var basketBallsCollection = [SCNNode]()
    var golfBallsCollection = [SCNNode]()
    var nerfDartsCollection = [SCNNode]()
    
    let total3DModelsNumber = 20
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Session configuring and running operation
        sceneView.autoenablesDefaultLighting = true
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap) )
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        print("called viewdidLoad")
        load3DModels()
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //Initial Hint for tapping
        UIView.animate(withDuration: 2, animations: {
            self.tapHintImageView.alpha = 1
        }, completion: {(terminated) in UIView.animate(withDuration: 2, animations: {
            self.tapHintImageView.alpha = 0
        })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// Custom animation applied after tapping on object
    func slideDown(_ node:SCNNode){
//        let collectionViewX = basketballCollectionView.frame.origin.x
//        let collectionViewY = basketballCollectionView.frame.origin.y
        
        let fadeOutAction = SCNAction.fadeOut(duration: 1)
        let moveToOriginAction = SCNAction.move(to: SCNVector3(0,0,0), duration: 1)
        node.runAction(fadeOutAction, completionHandler: {node.removeFromParentNode()
        })
        node.runAction(moveToOriginAction)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if hitTest.isEmpty{
            print("didn't touch anything")
        }
        else{
            let results = hitTest.first!
            let node = results.node
            let name = results.node.name
            
            slideDown(node)
            if(name == "Basketball"){
                //node.removeFromParentNode()
                basketballImages.append(basketballImage!)
                basketballCollectionView.reloadData()
            }else if(name == "GolfBall"){
                //node.removeFromParentNode()
                golfImages.append(golfBallImage!)
                golfCollectionView.reloadData()
            }else {
               //node.removeFromParentNode()
                nerfImages.append(nerfImage!)
                nerfCollectionView.reloadData()
            }
        }
    }
    
    func addNode(sceneName:String) -> SCNNode{
        let scene = SCNScene(named: sceneName)
        let node = scene?.rootNode.childNodes.first
        node?.position = SCNVector3(randomNumbers(firstNum: -3, secondNum: 3), randomNumbers(firstNum: 0.2, secondNum: 1.5), randomNumbers(firstNum: 2, secondNum: -2))
        node?.eulerAngles = SCNVector3(randomNumbers(firstNum: CGFloat(0.degreesToRadians), secondNum: CGFloat(360.degreesToRadians)),randomNumbers(firstNum: CGFloat(0.degreesToRadians), secondNum: CGFloat(360.degreesToRadians)),randomNumbers(firstNum: CGFloat(0.degreesToRadians), secondNum: CGFloat(360.degreesToRadians))
        )
        
        self.sceneView.scene.rootNode.addChildNode(node!)
        return node!
    }
    
//    Generates 20 random models
    func load3DModels() {
        
        for _ in 0..<total3DModelsNumber {
            let randomIndex = Int(randomNumbers(firstNum: 0, secondNum: 3))
            
            switch(randomIndex) {
            case 0: basketBallsCollection.append(addNode(sceneName: "Media.scnassets/Basketball.scn"))
                
            case 1: golfBallsCollection.append(addNode(sceneName: "Media.scnassets/Golfball.scn"))
                
            case 2: nerfDartsCollection.append(addNode(sceneName: "Media.scnassets/Nerf.scn"))
                
            default: return
                
            }
        }
    }
    
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    //Collection View delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == self.basketballCollectionView){
            return basketballImages.count
        } else if(collectionView == self.golfCollectionView){
            return golfImages.count
        } else {
            return nerfImages.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.basketballCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basketballCell", for: indexPath) as! BasketballCollectionViewCell
            
            cell.imageView.image = basketballImages[indexPath.row]
            return cell
        } else if(collectionView == self.golfCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "golfCell", for: indexPath) as! GolfCollectionViewCell
            
            cell.imageView.image = golfImages[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nerfCell", for: indexPath) as! NerfCollectionViewCell
            
            cell.imageView.image = nerfImages[indexPath.row]
            return cell
        }
    }
    
    //AUDIO SETTINGS
    func playSound(filename:String, fileextension:String, volume:Float) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileextension) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.volume = volume
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
