//
//  JogsViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit

class JogsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    // MARK: Properties
    
    var accessToken: String?
    @IBOutlet weak var jogsTableView: UITableView!
    fileprivate enum JogsVCError: Error {
        case unknownSegue
    }
    private let jogsRefreshControl = UIRefreshControl()
    @IBOutlet weak var addJogButton: UIBarButtonItem!
    private var user: User?
    private var jogs: [Jog]?
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: General Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        jogsTableView.delegate = self
        jogsTableView.dataSource = self
        if let accessToken = accessToken {
            getUser(accessToken: accessToken)
        }
        jogsTableView.refreshControl = jogsRefreshControl
        jogsRefreshControl.addTarget(self, action: #selector(refreshJogsTableView(_:)), for: .valueChanged)
    }
    
    // MARK: Action Methods
    
    @IBAction func backBarButtonItemPressed(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private Methods
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Showing Jogs Failed",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
    
    @objc private func refreshJogsTableView(_ sender: Any?) {
        if let accessToken = accessToken, let user = user {
            syncUsersAndJogs(accessToken: accessToken, passedUser: user)
            jogsRefreshControl.endRefreshing()
        }
    }
    
    private func startActivityIndicator() {
        jogsTableView.isUserInteractionEnabled = false
        jogsTableView.alpha = 0.5
        addJogButton.isEnabled = false
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    private func stopActivityIndicator() {
        jogsTableView.isUserInteractionEnabled = true
        jogsTableView.alpha = 1.0
        addJogButton.isEnabled = true
        spinner.stopAnimating()
        jogsTableView.reloadData()
    }

    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jogs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "JogTableViewCell"
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JogTableViewCell else {
            fatalError("The dequeued cell is not an instance of JogTableViewCell.")
        }
        
        guard let jogs = jogs else {
            return cell
        }
        
        let jog = jogs[indexPath.row]
        
        guard let identifier = jog.id, let distance = jog.distance, let time = jog.time, let date = jog.date?.performDateFormattingToString() else {
            return cell
        }
        
        cell.identifierLabel.text = "Jog #\(identifier)"
        cell.distanceLabel.text = "Distance: \(distance)"
        cell.timeLabel.text = "Time: \(time)"
        cell.dateLabel.text = "Date: \(date)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deletedJog = jogs?[indexPath.row], let accessToken = accessToken {
                jogs?.remove(at: indexPath.row)
                startActivityIndicator()
                deleteJog(passedJog: deletedJog, accessToken: accessToken)
            }
        }
    }
    
    // MARK: Network Methods
    
    private func getUser(accessToken: String) {
        DispatchQueue.main.async { [weak self] in
            self?.startActivityIndicator()
        }
        NetworkManager.getUser(accessToken: accessToken) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                    print("Get User Success. User: \(user.firstName ?? "wrong first name")")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.syncUsersAndJogs(accessToken: accessToken, passedUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func syncUsersAndJogs(accessToken: String, passedUser: User) {
        if user != nil {
            DispatchQueue.main.async { [weak self] in
                self?.startActivityIndicator()
            }
        }
        NetworkManager.syncUsersAndJogs(accessToken: accessToken) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let response):
                    self.jogs = response.jogs.filter { $0.userId == passedUser.id }
                    DispatchQueue.main.async {
                        self.stopActivityIndicator()
                        print("Sync jogs and user success")
                    }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showErrorAlert(error: error)
                }
            }
            
        }
    }
    
    private func deleteJog(passedJog: Jog, accessToken: String) {
        NetworkManager.deleteJog(jog: passedJog, accessToken: accessToken) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    print("\(response)")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showErrorAlert(error: error)

                }
            }
            
        }
    }
    
    private func updateJog(passedJog: Jog, accessToken: String) {
        NetworkManager.updateJog(jog: passedJog, accessToken: accessToken) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let user = self.user {
                        self.syncUsersAndJogs(accessToken: accessToken, passedUser: user)
                    }
                }
                print("\(response)")
            case .failure(let error):
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func addJog(passedJog: Jog, accessToken: String) {
        NetworkManager.addJog(jog: passedJog, accessToken: accessToken) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let user = self.user {
                        self.syncUsersAndJogs(accessToken: accessToken, passedUser: user)
                    }
                }
                print("\(response)")
            case .failure(let error):
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showErrorAlert(error: error)
                }
            }
            
        }
    }

    // MARK: - Navigation

    @IBAction func unwindToJogsVC(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditJogViewController, let jog = sourceViewController.jog, let accessToken = accessToken {
            startActivityIndicator()
            if let indexPath = sourceViewController.indexPathForEditMode {
                jogs?[indexPath.row] = jog
                jogsTableView.reloadRows(at: [indexPath], with: .none)
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.updateJog(passedJog: jog, accessToken: accessToken)
                }
            } else if let count = jogs?.count {
                let newIndexPath = IndexPath(row: count, section: 0)
                jogs?.append(jog)
                jogsTableView.insertRows(at: [newIndexPath], with: .automatic)
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.addJog(passedJog: jog, accessToken: accessToken)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "Add Jog":
            if let editJogVC = segue.destination.contents as? EditJogViewController {
                editJogVC.title = "Add a Jog"
                print("Add Jog Called")
            }
        case "Edit Jog":
            if let editJogVC = segue.destination.contents as? EditJogViewController, let selectedJogCell = sender as? JogTableViewCell, let indexPath = jogsTableView.indexPath(for: selectedJogCell) {
                editJogVC.indexPathForEditMode = indexPath
                let selectedJog = jogs?[indexPath.row]
                editJogVC.jog = selectedJog
                editJogVC.title = "Jog #\(selectedJog?.id ?? 0)"
            }
        default:
            showErrorAlert(error: JogsVCError.unknownSegue)
        }
    }

}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

extension Date {
    func performDateFormattingToString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateInString = dateFormatter.string(from: self)
        return dateInString
    }
}

extension JogsViewController.JogsVCError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknownSegue:
            return NSLocalizedString("Unexpected Segue Identifier.\nPlease report to the developer", comment: "Showing Jog Failed")
        }
    }
}

extension UIViewController {
    func hideKeyboardOnTouchUpInside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
