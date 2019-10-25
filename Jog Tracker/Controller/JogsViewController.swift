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
    
    private func performDateFormattingToString(date: Date?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        if let date = date {
            let dateInString = dateFormatter.string(from: date)
            return dateInString
        } else {
            print("Can't get a date")
            return nil
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
        
        guard let identifier = jog.id, let distance = jog.distance, let time = jog.time, let date = performDateFormattingToString(date: jog.date) else {
            return cell
        }
        
        cell.identifierLabel.text = "Jog #\(identifier)"
        cell.distanceLabel.text = "Distance: \(distance)"
        cell.timeLabel.text = "Time: \(time)"
        cell.dateLabel.text = "Date: \(date)"
        
        return cell
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
