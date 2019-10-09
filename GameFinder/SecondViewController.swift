//
//  SecondViewController.swift
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import Firebase


class SecondViewController: UIViewController, UITextFieldDelegate {
    
    var datePicker: UIDatePicker?
    
    // MARK: - Properties
    
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "alert-")
        return iv
    }()
    
    lazy var nameContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add-"), nameTextField)
    }()
    
    lazy var timeContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "alert_white-"), timeTextField)
    }()
    
    lazy var locationContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add_white-"), locationTextField)
    }()
    
    lazy var skillContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "ic_person_outline_white_2x"), skillTextField)
    }()
    
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Name of Event", isSecureTextEntry: false)
    }()
    
    lazy var timeTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Time of Event", isSecureTextEntry: false)
    }()
    
    
    lazy var locationTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Location of Event", isSecureTextEntry: false)
    }()
    
    lazy var skillTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Preferred Skill of Participants", isSecureTextEntry: false)
    }()
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CREATE EVENT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleCreateEvent), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    

    // MARK: - Init
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        nameTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        timeTextField.resignFirstResponder()
        skillTextField.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        nameTextField.delegate = self
        locationTextField.delegate = self
        timeTextField.delegate = self
        skillTextField.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Selectors
    
    @objc func handleCreateEvent() {
        print("in event handler")
        guard let name = nameTextField.text else { return }
        guard let time = timeTextField.text else { return }
        guard let location = locationTextField.text else { return }
        guard let skill = skillTextField.text else { return }
        createEvent(name: name, time: time, location: location, skill: skill)
        
    }
    
    
    // MARK: - API
    
    func createEvent(name: String, time: String, location: String, skill: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            
            let values = ["Skill": skill, "Time of event": time, "Location of event": location, "Creator": username]
            //EVENT CREATION IN DATABASE!!!!
             Database.database().reference().child("events").child(name + " Created by: " + username).updateChildValues(values, withCompletionBlock: { (error, ref) in
                 if let error = error {
                     print("Failed to update database values with error: ", error.localizedDescription)
                     return
                 }
             })
        }
        showToast(message: "Successfully Created an Event!")
        
    }
    // MARK: - Helper Functions
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d yyyy h:mm a"
        timeTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SecondViewController.viewTapped(gestureRecognizer:)))
    
    func configureViewComponents() {
        tabBarItem.title = "Create Event"
        view.backgroundColor = UIColor.mainBlue()
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(nameContainerView)
        nameContainerView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(timeContainerView)
        timeContainerView.anchor(top: nameContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        //Date Picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        datePicker?.addTarget(self, action: #selector(SecondViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        timeTextField.inputView = datePicker
        
        view.addSubview(locationContainerView)
        locationContainerView.anchor(top: timeContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(skillContainerView)
        skillContainerView.anchor(top: locationContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: skillContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
    }
}

