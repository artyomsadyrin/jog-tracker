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
    private var isLoginSuccess = false
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
            isLoginSuccess = false
            showErrorAlert(error: LoginError.emptyField)
            return
        }
        guard tempLoginCreds.contains(uuid) else {
            isLoginSuccess = false
            showErrorAlert(error: LoginError.noSuchUser)
            return
        }
        isLoginSuccess = true
        self.performSegue(withIdentifier: "Show Jogs", sender: self)
        print("Login success")
    }
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        
        switch identifier {
        case "Show Jogs":
            if isLoginSuccess {
                print("Segued to JogsVC")
                return true
            } else {
                return false
            }
        default:
            return true
        }
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
