//
//  JogsViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit

class JogsViewController: UIViewController
{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
    }
    
    @IBAction func backBarButtonItemPressed(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
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
