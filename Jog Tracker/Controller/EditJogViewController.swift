//
//  EditJogViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/24/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit
import os.log

class EditJogViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Public Properties
    
    @IBOutlet weak var jogTableView: UITableView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    
    var jog: Jog?
    var indexPathForEditMode: IndexPath?
    
    // MARK: Private Properties
    
    private var datePicker: UIDatePicker? {
        didSet { datePicker?.minimumDate = Date(timeIntervalSince1970: 0) }
    }
    
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
        dateTextField.addTarget(self, action: #selector(checkDateTextField(_:)), for: UIControl.Event.editingDidEnd)
        timeTextField.addTarget(self, action: #selector(checkTimeTextField(_:)), for: UIControl.Event.editingChanged)
        distanceTextField.addTarget(self, action: #selector(checkDistanceTextField(_:)), for: UIControl.Event.editingChanged)
        
        self.hideKeyboardOnTouchUpInside()
    }
    
    deinit {
        os_log(.debug, log: OSLog.default, "EditJogViewController deinited")
    }
    
    // MARK: Action Methods
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Text Fields Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
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
    
    private func showTextFieldError(_ textField: UITextField) {
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func hideTextFieldError(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
        textField.layer.borderColor = .none
    }
    
    @objc private func checkTimeTextField(_ textField: UITextField) {
        if isTimeTextFieldValid(textField) {
            hideTextFieldError(textField)
        } else {
            showTextFieldError(textField)
        }
    }
    
    @objc private func checkDistanceTextField(_ textField: UITextField) {
        if isDistanceTextFieldValid(textField) {
            hideTextFieldError(textField)
        } else {
            showTextFieldError(textField)
        }
    }
    
    @objc private func checkDateTextField(_ textField: UITextField) {
        if isDateTextFieldValid(textField) {
            hideTextFieldError(textField)
        } else {
            showTextFieldError(textField)
        }
    }
    
    private func isTimeTextFieldValid(_ textField: UITextField) -> Bool {
        if let text = textField.text, Int(text) != nil {
            return true
        } else {
            return false
        }
    }
    
    private func isDistanceTextFieldValid(_ textField: UITextField) -> Bool {
        if let text = textField.text, Double(text) != nil {
            return true
        } else {
            return false
        }
    }
    
    private func isDateTextFieldValid(_ textField: UITextField) -> Bool {
        if let text = textField.text, getDateFromTextFieldText(text: text) != nil {
            return true
        } else {
            return false
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
        if textField.isEditing, let datePicker = datePicker, textField.inputView == datePicker {
            textField.text = datePicker.date.performDateFormattingToString()
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        
        switch identifier {
        case "Save Jog":
            if ( !dateTextField.isEmpty && !timeTextField.isEmpty && !distanceTextField.isEmpty ) &&
                ( isDateTextFieldValid(dateTextField) && isTimeTextFieldValid(timeTextField) && isDistanceTextFieldValid(distanceTextField) ) {
                return true
            } else {
                checkDateTextField(dateTextField)
                checkTimeTextField(timeTextField)
                checkDistanceTextField(distanceTextField)
                return false
            }
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let dateString = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let date = getDateFromTextFieldText(text: dateString),
            let timeString = timeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let time = Int(timeString),
            let distanceString = distanceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let distance = Double(distanceString) {
            if jog != nil {
                jog?.date = date
                jog?.time = time
                jog?.distance = distance
            } else {
                jog = Jog(identifier: nil, userId: nil, distance: distance, time: time, date: date)
            }
        } else {
            os_log(.error, log: OSLog.default, "Couldn't get parameter(-s) for saving jog")
        }
    }
    
}
