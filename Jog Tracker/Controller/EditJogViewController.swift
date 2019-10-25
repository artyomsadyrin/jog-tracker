//
//  EditJogViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit

class EditJogViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var jogTableView: UITableView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var distanceTextField: UITextField!
    private var pickedDate: Date?
    private var datePicker: UIDatePicker? {
        didSet { datePicker?.minimumDate = Date(timeIntervalSince1970: 0) }
    }
    var jog: Jog?
    var indexPathForEditMode: IndexPath?
    
    // MARK: General Methods
    
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
        setUpDatePicker()
        dateTextField.inputAccessoryView = addOnlyToolbarDoneButton()
        timeTextField.inputAccessoryView = addOnlyToolbarDoneButton()
        distanceTextField.inputAccessoryView = addOnlyToolbarDoneButton()
        self.hideKeyboardOnTouchUpInside()
    }
    
    // MARK: Action Methods
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: Text Fields Methods
    
    private func addOnlyToolbarDoneButton() -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc private func doneButtonAction() {
        if dateTextField.isEditing {
            dateTextField.resignFirstResponder()
        }
        if timeTextField.isEditing {
            timeTextField.resignFirstResponder()
        }
        if distanceTextField.isEditing {
            distanceTextField.resignFirstResponder()
        }
    }
    
    // MARK: Private Methods
    
    private func getDateFromTextFieldText(text: String?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        if let text = text, let date = dateFormatter.date(from: text) {
            return date
        } else {
            return nil
        }
    }
    
    // MARK: Date Picker Methods
    
    private func setUpDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = Locale(identifier: "en_US")
        dateTextField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        if let jog = jog, let date = jog.date {
            datePicker?.setDate(date, animated: false)
        } else {
            let nowDate = Date(timeIntervalSinceNow: 0)
            dateTextField.text = nowDate.performDateFormattingToString()
        }
    }
    
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        dateTextField.text = datePicker.date.performDateFormattingToString()
    }
    
    private func dateFieldDoneButtonAction(textField: UITextField, datePicker: UIDatePicker?) {
        if textField.isEditing {
            if let datePicker = datePicker {
                if textField.inputView == datePicker {
                    textField.text = datePicker.date.performDateFormattingToString()
                }
            }
            textField.resignFirstResponder()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let dateString = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let date = getDateFromTextFieldText(text: dateString),
            let timeString = timeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let time = Int(timeString), let distanceString = distanceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let distance = Double(distanceString) {
            if jog != nil {
                jog?.date = date
                jog?.time = time
                jog?.distance = distance
            } else {
                jog = Jog(id: nil, userId: nil, distance: distance, time: time, date: date)
            }
        }
    }

}
