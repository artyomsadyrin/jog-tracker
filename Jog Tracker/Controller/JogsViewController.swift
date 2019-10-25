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
        jogsRefreshControl.addTarget(self, action: #selector(refreshJogsTableView), for: .valueChanged)
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
    
    @objc private func refreshJogsTableView() {
        if let accessToken = accessToken, let user = user {
            syncUsersAndJogs(accessToken: accessToken, passedUser: user)
        }
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
                jogsTableView.isUserInteractionEnabled = false
                jogsTableView.alpha = 0.5
                addJogButton.isEnabled = false
                spinner.isHidden = false
                spinner.startAnimating()
                deleteJog(passedJog: deletedJog, accessToken: accessToken)
            }
        }
    }
    
    // MARK: Network Methods
    
    private func getUser(accessToken: String) {
        spinner.isHidden = false
        spinner.startAnimating()
        NetworkManager.getUser(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.user = user
                    print("Get User Success. User: \(user.firstName ?? "wrong first name")")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.syncUsersAndJogs(accessToken: accessToken, passedUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func syncUsersAndJogs(accessToken: String, passedUser: User) {
        NetworkManager.syncUsersAndJogs(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let response):
                    self?.jogs = response.jogs.filter { $0.userId == passedUser.id }
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        self?.jogsTableView.reloadData()
                        print("Sync jogs and user success")
                    }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showErrorAlert(error: error)
                }
            }
            
        }
    }
    
    private func deleteJog(passedJog: Jog, accessToken: String) {
        NetworkManager.deleteJog(jog: passedJog, accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.jogsTableView.isUserInteractionEnabled = true
                    self?.jogsTableView.alpha = 1.0
                    self?.addJogButton.isEnabled = true
                    self?.jogsTableView.reloadData()
                    print("\(response)")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.showErrorAlert(error: error)

                }
            }
            
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "Add Jog":
            if let _ = segue.destination.contents as? EditJogViewController {
                print("Add Jog Happening")
            }
        case "Edit Jog":
            if let editJogVC = segue.destination.contents as? EditJogViewController, let selectedJogCell = sender as? JogTableViewCell, let indexPath = jogsTableView.indexPath(for: selectedJogCell) {
                let selectedJog = jogs?[indexPath.row]
                editJogVC.jog = selectedJog
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
