//
//  HomeViewController.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 30/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpButton.layer.cornerRadius = helpButton.bounds.height / 2
        helpButton.backgroundColor = .red
        playButton.layer.cornerRadius = playButton.bounds.height / 2
        playButton.backgroundColor = .red
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let gameScore = defaults.value(forKey: "score"){
            let score = gameScore as! Int
            scoreLabel.text = "Last Score: \(score)"
        }
    }
    
    // MARK: - Buttons
    
    // El botón help nos lleva al viewcontroller que contiene la ayuda
    @IBAction func helpAction(_ sender: Any) {
        performSegue(withIdentifier: "homeToHelpSegue", sender: self)
    }
    
    // El botón play nos lleva al viewcontroller que contiene el juego
    @IBAction func playAction(_ sender: Any) {
        performSegue(withIdentifier: "homeToGameSegue", sender: self)
    }
}
