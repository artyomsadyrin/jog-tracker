//
//  JogsViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit
import os.log

protocol JogsViewControllerDelegate: class {
    func updateReportTableView()
}

class JogsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Public Properties
    weak var delegate: JogsViewControllerDelegate?
    @IBOutlet weak var jogsTableView: UITableView!
    @IBOutlet weak var addJogButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.madeAdaptable()
        }
    }
    
    // MARK: Private Properties
    
    fileprivate enum JogsVCError: Error {
        case unknownSegue
    }
    private var isDeletionHappening = false
    private let jogsRefreshControl = UIRefreshControl()
    private var user: User?
    private var jogs: [Jog]?
    
    // MARK: General Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        jogsTableView.delegate = self
        jogsTableView.dataSource = self
        getUser()
        jogsTableView.refreshControl = jogsRefreshControl
        jogsRefreshControl.addTarget(self, action: #selector(refreshJogsTableView(_:)), for: .valueChanged)
    }
    
    deinit {
        os_log(.debug, log: OSLog.default, "JogsViewController deinited")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDeletionHappening = false
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
        if let user = user {
            syncUsersAndJogs(passedUser: user)
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
        
        guard let identifier = jog.identifier, let distance = jog.distance, let time = jog.time, let date = jog.date?.performDateFormattingToString() else {
            return cell
        }
        
        cell.identifierLabel.text = "Jog #\(identifier)"
        cell.distanceLabel.text = "Distance: \(distance)"
        cell.timeLabel.text = "Time: \(time)"
        cell.dateLabel.text = "Date: \(date)"
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deletedJog = jogs?[indexPath.row] {
                jogs?.remove(at: indexPath.row)
                startActivityIndicator()
                isDeletionHappening = true
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.deleteJog(passedJog: deletedJog)
                }
            }
        }
    }
    
    // MARK: Network Methods
    
    private func getUser() {
        DispatchQueue.main.async { [weak self] in
            self?.startActivityIndicator()
        }
        NetworkManager.getUser { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                    os_log(.debug, log: OSLog.default, "Get user success")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.syncUsersAndJogs(passedUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func syncUsersAndJogs(passedUser: User) {
        if user != nil || !isDeletionHappening {
            DispatchQueue.main.async { [weak self] in
                self?.startActivityIndicator()
            }
        }
        NetworkManager.syncUsersAndJogs { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let response):
                    self.jogs = response.jogs.filter { $0.userId == passedUser.identifier }
                    DispatchQueue.main.async {
                        self.stopActivityIndicator()
                        self.delegate?.updateReportTableView()
                        os_log(.debug, log: OSLog.default, "JogsVC: Sync users and jogs success")
                    }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showErrorAlert(error: error)
                }
            }
            
        }
    }
    
    private func deleteJog(passedJog: Jog) {
        NetworkManager.deleteJog(jog: passedJog) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    os_log(.debug, log: OSLog.default, "Delete jog success")
                    if let user = self.user {
                        self.syncUsersAndJogs(passedUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showErrorAlert(error: error)

                }
            }
            
        }
    }
    
    private func updateJog(passedJog: Jog) {
        NetworkManager.updateJog(jog: passedJog) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    os_log(.debug, log: OSLog.default, "Update user success")
                    if let user = self.user {
                        self.syncUsersAndJogs(passedUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func addJog(passedJog: Jog) {
        NetworkManager.addJog(jog: passedJog) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    os_log(.debug, log: OSLog.default, "Add jog success")
                    if let user = self.user {
                        self.syncUsersAndJogs(passedUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showErrorAlert(error: error)
                }
            }
            
        }
    }

    // MARK: - Navigation

    @IBAction func unwindToJogsVC(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditJogViewController, let jog = sourceViewController.jog {
            startActivityIndicator()
            if sourceViewController.indexPathForEditMode != nil {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.updateJog(passedJog: jog)
                }
            } else {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.addJog(passedJog: jog)
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
            }
        case "Edit Jog":
            if let editJogVC = segue.destination.contents as? EditJogViewController, let selectedJogCell = sender as? JogTableViewCell, let indexPath = jogsTableView.indexPath(for: selectedJogCell) {
                editJogVC.indexPathForEditMode = indexPath
                let selectedJog = jogs?[indexPath.row]
                editJogVC.jog = selectedJog
                editJogVC.title = "Jog #\(selectedJog?.identifier ?? 0)"
            }
        default:
            showErrorAlert(error: JogsVCError.unknownSegue)
        }
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
