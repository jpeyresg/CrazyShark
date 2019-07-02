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
    
    // MARK: - ViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateBackground), userInfo: nil, repeats: true)
    }
    
    // MARK: - Animation functions
    
    // Debido a que en IOS la LaunchScreen es estática, para animarla hay que recurrir a un viewcontroller
    
    // Esta función es llamada por el backgroundTimer cada 0.1 segundos y va alternando las
    // imágenes de fondo hasta que llega a dos segundos
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
