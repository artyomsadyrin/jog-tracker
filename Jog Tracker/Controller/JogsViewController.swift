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
    
    private struct Jog {
        var distance: Double
        var time: Int
        var date: String
        
    }
    
    @IBOutlet weak var jogsTableView: UITableView!
    
    private var jogs: [Jog] = [
        Jog(distance: 2.2, time: 10, date: "July 10"),
        Jog(distance: 3.9, time: 20, date: "August 1"),
        Jog(distance: 4.4, time: 32, date: "September 9"),
        Jog(distance: 1.3, time: 2, date: "September 30"),
        Jog(distance: 10.2, time: 90, date: "October 31")
    ]
    
    // MARK: General Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        jogsTableView.delegate = self
        jogsTableView.dataSource = self
    }
    
    // MARK: Action Methods
    
    @IBAction func backBarButtonItemPressed(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "JogTableViewCell"
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JogTableViewCell else {
            fatalError("The dequeued cell is not an instance of JogTableViewCell.")
        }
        let jog = jogs[indexPath.row]
        cell.identifierLabel.text = "Jog #\(indexPath.row)"
        cell.distanceLabel.text = "Distance: \(jog.distance)"
        cell.timeLabel.text = "Time: \(jog.time)"
        cell.dateLabel.text = "Date: \(jog.date)"
        
        return cell
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
