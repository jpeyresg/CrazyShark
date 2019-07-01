//
//  SplashViewController.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 01/07/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    var backgroundTimer : Timer?
    var counter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateBackground), userInfo: nil, repeats: true)
    }
    
    @objc func updateBackground() {
        if counter == 20 {
            backgroundTimer?.invalidate()
            performSegue(withIdentifier: "splashToHomeSegue", sender: self)
        } else {
            if (counter % 2) == 0 {
                backgroundImage.image = UIImage(named: "introBackground1")
            } else {
                backgroundImage.image = UIImage(named: "introBackground2")
            }
            counter += 1
        }
    }

}
