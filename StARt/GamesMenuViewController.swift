//
//  GamesMenuViewController.swift
//  EasyLearn
//
//  Created by Califano Francesco on 07/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit

class GamesMenuViewController: UIViewController {

    @IBOutlet weak var menuImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imgArray = [UIImage]()
        imgArray.append(UIImage(named:"Background-1")!)
        imgArray.append(UIImage(named:"Background-2")!)
        
        
        menuImageView.animationImages = imgArray
        menuImageView.animationDuration = 0.5
        menuImageView.animationRepeatCount = 10000
        menuImageView.startAnimating()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
