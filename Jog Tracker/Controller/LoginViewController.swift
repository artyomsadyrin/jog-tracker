//
//  LoginViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/23/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    
    // MARK: Properties
 
    private var tempLoginCreds = ["hello"]
    @IBOutlet weak var uuidTextField: UITextField!
    
    fileprivate enum LoginError: Error {
        case emptyField
        case noSuchUser
    }
    
    // MARK: General Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        uuidTextField.delegate = self
    }
    
    // MARK: Private Methods
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Login Failed",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: Action Methods

    @IBAction func logIn(_ sender: UIButton) {
        guard let uuid = uuidTextField.text, !uuid.isEmpty else {
            showErrorAlert(error: LoginError.emptyField)
            return
        }
        guard tempLoginCreds.contains(uuid) else {
            showErrorAlert(error: LoginError.noSuchUser)
            return
        }
        print("Login success")
    }

}

extension LoginViewController.LoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyField:
            return NSLocalizedString("Text field is empty. Please enter your UUID.", comment: "Empty Field")
        case .noSuchUser:
            return NSLocalizedString("Can't find a user with given UUID.", comment: "No Such User")
        }
    }
}

