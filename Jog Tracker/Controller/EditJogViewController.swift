//
//  EditJogViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit

class EditJogViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var jogTableView: UITableView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var distanceTextField: UITextField!
    
    var jog: Jog?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jogTableView.dataSource = self
        jogTableView.delegate = self
        dateTextField.delegate = self
        timeTextField.delegate = self
        distanceTextField.delegate = self
        if let jog = jog {
            dateTextField.text = jog.date?.performDateFormattingToString()
            timeTextField.text = jog.time?.description
            distanceTextField.text = jog.distance?.description
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
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
