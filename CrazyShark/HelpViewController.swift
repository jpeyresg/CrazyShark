//
//  HelpViewController.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 30/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var menuButton: UIButton!
    
    // MARK: - ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()

        menuButton.backgroundColor = .red
        menuButton.layer.cornerRadius = menuButton.bounds.height / 2
    }
    
    // MARK: - Buttons
    
    // El botón menu nos lleva de vuelta al viewcontroller que contiene el menu
    @IBAction func menuAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
