//
//  HomeViewController.swift
//  StARt
//
//  Created by Califano Francesco on 08/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var joinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        var imgArray = [UIImage]()
        imgArray.append(UIImage(named:"JoinITA-1")!)
        imgArray.append(UIImage(named:"JoinITA-2")!)
        
        joinButton.imageView?.animationImages = imgArray
        joinButton.imageView?.animationDuration = 0.5
        joinButton.imageView?.animationRepeatCount = 10000
        joinButton.imageView?.startAnimating()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
