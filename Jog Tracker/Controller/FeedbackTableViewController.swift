//
//  FeedbackTableViewController.swift
//  Jog Tracker
//
//  Created by Artyom Sadyrin on 10/28/19.
//  Copyright © 2019 Artyom Sadyrin. All rights reserved.
//

import UIKit
import os.log

class FeedbackTableViewController: UITableViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Public Properties
    
    @IBOutlet weak var topicIdTextField: UITextField!
    @IBOutlet weak var feedbackTextView: UITextView!
    var accessToken: String?
    
    // MARK: Private Properties
    
    private let placeholderForFeedbackTextView = "Enter your feedback text"
    private var feedback: Feedback?
    private var pickedTopicId: TopicId?
    private let topicIdPickerData: [TopicId] = TopicId.allCases
    private var topicIdPickerView = UIPickerView()
    
    // MARK: General Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTouchUpInside()
        os_log(.debug, log: OSLog.default, "FeedbackVC loaded")
        
        feedbackTextView.delegate = self
        addPlacehoderToTextView(feedbackTextView)
        
        setUpTopicIdPickerView()
        topicIdTextField.inputAccessoryView = addOnlyToolbarDoneButton()
    }
    
    deinit {
        os_log(.debug, log: OSLog.default, "FeedbackTVC deinited")
    }
    
    // MARK: Private Methods
    
    private func showSavingAlert(result: Result<String, Error>) {
        var message = String()
        
        switch result {
        case .success(let response):
            message = response
        case .failure(let error):
            message = "\(error.localizedDescription)"
        }
        
        let alert = UIAlertController(
            title: "Feedback Saving",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
    
    private func reverseFieldsToDefaultState() {
        feedback = nil
        setDefaultValueForTopicIdPickerView()
        addPlacehoderToTextView(feedbackTextView)
    }
    
    // MARK: TextField Methods
    
    private func addOnlyToolbarDoneButton() -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc private func doneButtonAction() {
        if topicIdTextField.isEditing {
            topicIdTextField.resignFirstResponder()
        }
    }
    
    // MARK: TextView Methods
    
    private func addPlacehoderToTextView(_ textView: UITextView) {
        textView.text = placeholderForFeedbackTextView
        textView.textColor = UIColor.lightGray
    }
    
    private func removePlaceholderFromTextView(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = UIColor.black
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            removePlaceholderFromTextView(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            addPlacehoderToTextView(textView)
        }
    }
    
    private func showTextViewError(_ textView: UITextView) {
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.red.cgColor
    }
    
    private func hideTextViewError(_ textView: UITextView) {
        textView.layer.borderWidth = 0.0
        textView.layer.borderColor = .none
    }
    
    private func isTextViewEmpty(for textView: UITextView, with placeholder: String) -> Bool {
        if textView.text != placeholder && !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func checkFeedbackTextView(_ textView: UITextView) {
        if isTextViewEmpty(for: textView, with: placeholderForFeedbackTextView) {
            showTextViewError(textView)
        } else {
            hideTextViewError(textView)
        }
    }
    
    // MARK: Picker View Methods
    
    private func setUpTopicIdPickerView() {
        topicIdPickerView.delegate = self
        topicIdPickerView.dataSource = self
        topicIdTextField.inputView = topicIdPickerView
        
        topicIdPickerView.selectRow(0, inComponent: 0, animated: false)
        setDefaultValueForTopicIdPickerView()
    }
    
    private func setDefaultValueForTopicIdPickerView() {
        if let topicId = topicIdPickerData.first {
            pickedTopicId = topicId
            topicIdTextField.text = topicId.rawValue.description
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case topicIdPickerView:
            return topicIdPickerData.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case topicIdPickerView:
            return topicIdPickerData[row].rawValue.description
        default:
            os_log("Can't recognize pickerView for setting title", log: OSLog.default, type: .debug)
            return "Unknown"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case topicIdPickerView:
            pickedTopicId = topicIdPickerData[row]
            topicIdTextField.text = pickedTopicId?.rawValue.description
        default:
            os_log("Unknowned pickerView did selected", log: OSLog.default, type: .debug)
        }
    }
    
    // MARK: Action Methods
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
        
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard !isTextViewEmpty(for: feedbackTextView, with: placeholderForFeedbackTextView) else {
            checkFeedbackTextView(feedbackTextView)
            os_log(.debug, log: OSLog.default, "Error in feedback saving")
            return
        }
        
        guard let topicId = pickedTopicId, let accessToken = accessToken else {
            os_log(.error, log: OSLog.default, "Can't get topic id or access token")
            return
        }
        
        checkFeedbackTextView(feedbackTextView)
        feedback = Feedback(topicId: topicId.rawValue, text: feedbackTextView.text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let feedback = self?.feedback else {
                return
            }
            self?.sendFeedback(passedFeedback: feedback, accessToken: accessToken)
        }
    }
    
    // MARK: Network Methods
    
    private func sendFeedback(passedFeedback: Feedback, accessToken: String) {
        NetworkManager.sendFeedback(feedback: passedFeedback, accessToken: accessToken) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.reverseFieldsToDefaultState()
                    self.showSavingAlert(result: result)
                    os_log(.debug, log: OSLog.default, "Send feedback success")
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showSavingAlert(result: result)
                }
            }
        }
    }
    
}
