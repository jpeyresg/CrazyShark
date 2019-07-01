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
    override func viewDidLoad() {
        super.viewDidLoad()

        menuButton.backgroundColor = .red
        menuButton.layer.cornerRadius = menuButton.bounds.height / 2
    }
    
    @IBAction func menuAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
