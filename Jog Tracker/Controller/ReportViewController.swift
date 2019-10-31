//
//  ReportViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/29/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit
import os.log

class ReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, JogsViewControllerDelegate {
    
    // MARK: Public Properties
    
    var reports: [Report]?
    var accessToken: String?
    
    @IBOutlet weak var reportTableView: UITableView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.madeAdaptable()
        }
    }
    
    // MARK: Private Properties
    
    private var user: User?
    private var isReportsAscendingOrder = true
    private let reportsRefreshControl = UIRefreshControl()
    
    // MARK: General Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportTableView.delegate = self
        reportTableView.dataSource = self
        
        if let accessToken = accessToken {
            getUser(accessToken: accessToken)
        }
        
        reportTableView.refreshControl = reportsRefreshControl
        reportsRefreshControl.addTarget(self, action: #selector(refreshReportTableView(_:)), for: .valueChanged)
    }
    
    deinit {
        os_log(.debug, log: OSLog.default, "ReportVC deinited")
    }
    
    // MARK: Activity Indicator Methods
    
    private func startActivityIndicator() {
        reportTableView.alpha = 0.5
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    private func stopActivityIndicator() {
        reportTableView.alpha = 1.0
        spinner.stopAnimating()
        reportTableView.reloadData()
    }
    
    // MARK: JogsViewController Delegate
    
    func updateReportTableView() {
        if let accessToken = accessToken, let user = user {
            syncUsersAndJogs(accessToken: accessToken, passedUser: user)
        }
    }
    
    // MARK: Private Methods
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Showing Jogs Report Failed",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
    
    private func groupJogs(jogs: [Jog], reports: inout [Report]?) {
        let groupedJogs = jogs.groupedBy(dateComponent: .weekOfYear)
        reports = [Report]()
        
        for (interval, jogs) in groupedJogs {
            let report = Report(weekInterval: interval, jogs: jogs)
            reports?.append(report)
        }
        
        reports?.sort(by: { $0.weekInterval < $1.weekInterval })
        isReportsAscendingOrder = true
        
        DispatchQueue.main.async { [weak self] in
            self?.stopActivityIndicator()
            os_log(.debug, log: OSLog.default, "Group jogs by week success")
        }
    }
    
    @objc private func refreshReportTableView(_ sender: Any?) {
        if let accessToken = accessToken, let user = user {
            syncUsersAndJogs(accessToken: accessToken, passedUser: user)
            reportsRefreshControl.endRefreshing()
        }
    }
    
    // MARK: Action Methods
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func sort(_ sender: UIBarButtonItem) {
        if reports != nil {
            if isReportsAscendingOrder {
                reports?.sort(by: { $0.weekInterval > $1.weekInterval })
                reportTableView.reloadData()
                isReportsAscendingOrder = false
            } else {
                reports?.sort(by: { $0.weekInterval < $1.weekInterval })
                isReportsAscendingOrder = true
                reportTableView.reloadData()
            }
        }
    }
    
    // MARK: Table View DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ReportTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReportTableViewCell else {
            fatalError("The dequeued cell is not an instance of ReportTableViewCell.")
        }
        
        guard let reports = reports else {
            return cell
        }
        
        let report = reports[indexPath.row]
        
        if let weekInterval = report.weekInterval.formatToString()?.replacingOccurrences(of: "–", with: "/"),
            let numberOfWeek = report.getNumberOfWeek() {
            cell.intervalLabel.text = "Week \(numberOfWeek): (\(weekInterval))"
        }
        cell.avgSpeedLabel.text = String(format: "Av. Speed: %.2f", report.getAvgSpeed())
        cell.avgTimeLabel.text = String(format: "Av. Time: %.2f", report.getAvgTime())
        cell.totalDistanceLabel.text = String(format: "Total Distance: %.2f", report.getTotalDistance())
        
        return cell
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
                    os_log(.debug, log: OSLog.default, "Get user success")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.syncUsersAndJogs(accessToken: accessToken, passedUser: user)
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
                os_log(.debug, log: OSLog.default, "ReportsVC: Sync users and jogs success")
                let jogs = response.jogs.filter { $0.userId == passedUser.identifier }
                self.groupJogs(jogs: jogs, reports: &self.reports)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.showErrorAlert(error: error)
                }
            }
            
        }
    }
    
}
