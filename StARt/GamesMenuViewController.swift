//
//  GamesMenuViewController.swift
//  EasyLearn
//
//  Created by Califano Francesco on 07/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit

class GamesMenuViewController: UIViewController {

    var imgBasketArray = [UIImage]()
    var imgBalloonsArray = [UIImage]()
    
    @IBOutlet weak var basketButton: UIButton!
    @IBOutlet weak var balloonsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBasketArray.append(UIImage(named:"Basket-1")!)
        imgBasketArray.append(UIImage(named:"Basket-2")!)
        
        imgBalloonsArray.append(UIImage(named:"Balloons-1")!)
        imgBalloonsArray.append(UIImage(named:"Balloons-2")!)
    }

    override func viewDidAppear(_ animated: Bool) {
        animateButton(images: imgBasketArray, button: basketButton)
        animateButton(images: imgBalloonsArray, button: balloonsButton)
    }
    func animateButton(images: [UIImage], button: UIButton){
        button.imageView?.animationImages = images
        button.imageView?.animationDuration = 0.5
        button.imageView?.animationRepeatCount = 10000
        button.imageView?.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
