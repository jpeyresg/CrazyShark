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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpButton.layer.cornerRadius = helpButton.bounds.height / 2
        helpButton.backgroundColor = .red
        playButton.layer.cornerRadius = playButton.bounds.height / 2
        playButton.backgroundColor = .red
    }
    
    @IBAction func helpAction(_ sender: Any) {
        performSegue(withIdentifier: "homeToHelpSegue", sender: self)
    }
    
    @IBAction func playAction(_ sender: Any) {
        performSegue(withIdentifier: "homeToGameSegue", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
