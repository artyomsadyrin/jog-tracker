//
//  LoginViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/23/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit
import os.log

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Public Properties

    var authResponse: AuthResponse?
    var isLoginSuccess = false
    @IBOutlet weak var uuidTextField: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.madeAdaptable()
        }
    }
    
    // MARK: Private Properties
    
    fileprivate enum LoginError: Error {
        case emptyField
        case unknownSegue
    }
    
    // MARK: General Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        uuidTextField.delegate = self
        self.hideKeyboardOnTouchUpInside()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isLoginSuccess = false
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
        logInWithUUID()
        return textField.resignFirstResponder()
    }
    
    // MARK: Network Methods
    
    private func logInWithUUID() {
        guard let uuid = uuidTextField.text, !uuid.isEmpty else {
            showErrorAlert(error: LoginError.emptyField)
            return
        }
        spinner.isHidden = false
        spinner.startAnimating()
        NetworkManager.uuidLogin(uuid: uuid) { [weak self] result in
            switch result {
            case .success(let authResponse):
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.isLoginSuccess = true
                    self?.authResponse = authResponse
                    os_log(.debug, log: OSLog.default, "Login success")
                    self?.performSegue(withIdentifier: "Show Jogs", sender: nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoginSuccess = false
                    self?.spinner.stopAnimating()
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    // MARK: Action Methods

    @IBAction func logIn(_ sender: UIButton) {
        logInWithUUID()
    }
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if isLoginSuccess {
            return true
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case "Show Jogs":
            if let tabBarVC = segue.destination as? UITabBarController,
                let jogsVC = tabBarVC.viewControllers?[0].contents as? JogsViewController,
                let reportVC = tabBarVC.viewControllers?[2].contents as? ReportViewController {
                jogsVC.delegate = reportVC
            }
        default:
            showErrorAlert(error: LoginError.unknownSegue)
        }
    }

}

extension LoginViewController.LoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyField:
            return NSLocalizedString("Text field is empty.\nPlease enter your UUID.", comment: "Login Failed")
        case .unknownSegue:
            return NSLocalizedString("Unexpected Segue Identifier.\nPlease report to the developer", comment: "Login Failed")
        }
    }
}
