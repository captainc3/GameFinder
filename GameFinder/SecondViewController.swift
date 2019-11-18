//
//  SecondViewController.swift
//  CREATE AN EVENT PAGE
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds


class SecondViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
       bannerView.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(bannerView)
       view.addConstraints(
         [NSLayoutConstraint(item: bannerView,
                             attribute: .bottom,
                             relatedBy: .equal,
                             toItem: bottomLayoutGuide,
                             attribute: .top,
                             multiplier: 1,
                             constant: 0),
          NSLayoutConstraint(item: bannerView,
                             attribute: .centerX,
                             relatedBy: .equal,
                             toItem: view,
                             attribute: .centerX,
                             multiplier: 1,
                             constant: 0)
         ])
      }
    
    
    //var datePicker: UIDatePicker?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var skillPicker: UIPickerView!
    var skillPickerData : [String] = [String]()
    var locationPickerData : [String] = [String]()
    var categoryPickerData : [String] = [String]()

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
    
    /*let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "GameFinder1")
        return iv
    }()*/
    
    lazy var categoryContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add_white-"), categoryTextField)
    }()
    
    lazy var nameContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add_white-"), nameTextField)
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
    
    lazy var categoryTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Event Category", isSecureTextEntry: false)
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
        return true
    }
    
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        categoryTextField.delegate = self
        categoryPickerData = ["Basketball", "Board Games","Card Games", "Football", "Frisbee", "Local Video Games", "Ping Pong", "Racquetball", "Soccer"]
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.isHidden = true
        nameTextField.delegate = self
        locationTextField.delegate = self
        timeTextField.delegate = self
        skillTextField.delegate = self
        skillPickerData = ["Casual", "Moderate", "Advanced"]
        skillPicker.delegate = self
        skillPicker.dataSource = self
        skillPicker.isHidden = true
        locationPickerData = ["Burger Field", "College of Computing", "College of Design", "CRC", "CULC", "Klaus", "Peters Parking Deck", "SAC Fields", "Student Center", "Tech Green", "West Village"]
        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationPicker.isHidden = true
        datePicker.isHidden = true
        
        let logo = UIImage(named: "GameFinder3.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Do any additional setup after loading the view.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    
    //preventing rotation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleCreateEvent() {
        print("in event handler")
        
        //PRINTS ALL EVENTS BEGIN
        let fcmTokenRef = Database.database().reference()
            fcmTokenRef.observe(.childAdded, with: { (snapshot) in
            print(">>",snapshot)
             guard let data = snapshot as? NSDictionary else {return}
             var each_token = data["fcmToken"] as? String
             print("all tokens: \(each_token!)")
        })
        //PRINTS ALL EVENTS END
        guard let category = categoryTextField.text else { return }
        guard let name = nameTextField.text else { return }
        guard let time = timeTextField.text else { return }
        guard let location = locationTextField.text else { return }
        guard let skill = skillTextField.text else { return }
        if ((category  == "") || (name  == "") || (time  == "") || (location  == "") || (skill  == "")) {
            showToast(message: "Please fill in all required fields.")
        } else {
            createEvent(category: category, name: name, time: time, location: location, skill: skill)
            showToast(message: "Successfully Created an Event!")
        }
        
    }
    
    
    // MARK: - API
    
    func createEvent(category: String, name: String, time: String, location: String, skill: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            
            let values = ["Category": category, "Skill": skill, "Time of event": time, "Location of event": location, "Creator": username]
            //EVENT CREATION IN DATABASE!!!!
             Database.database().reference().child("events").child(name + " Created by: " + username).updateChildValues(values, withCompletionBlock: { (error, ref) in
                 if let error = error {
                     print("Failed to update database values with error: ", error.localizedDescription)
                     return
                 }
             })
        }
        
    }
    // MARK: - Helper Functions
    
    @IBAction func datePickerChanged(_ sender: Any) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "E, MMM d yyyy h:mm a"
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.day = 3 //ONLY PICK DATE WITHIN 72 HOURS
        let maxDate = calendar.date(byAdding: comps, to: Date())
        comps.day = 0 //TODAYs DATE
        let minDate = calendar.date(byAdding: comps, to: Date())
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
        let strDate = dateFormatter.string(from: datePicker.date)
        timeTextField.text = strDate
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == skillPicker) {
            return skillPickerData.count
        } else if (pickerView == categoryPicker) {
            return categoryPickerData.count
        }
        return locationPickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == skillPicker) {
            return skillPickerData[row]
        } else if (pickerView == locationPicker) {
            return locationPickerData[row]
        } else if (pickerView == categoryPicker) {
            return categoryPickerData[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == skillPicker) {
            skillTextField.text = skillPickerData[row]
        } else if (pickerView == locationPicker) {
            locationTextField.text = locationPickerData[row]
        } else if (pickerView == categoryPicker) {
            categoryTextField.text = categoryPickerData[row]
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == skillTextField){
            skillPicker.isHidden = true
        } else if (textField == locationTextField) {
            locationPicker.isHidden = true
        } else if (textField == timeTextField) {
            datePicker.isHidden = true
        } else if (textField == categoryTextField) {
            categoryPicker.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == skillTextField){
            skillPicker.isHidden = false
        } else if (textField == locationTextField) {
            locationPicker.isHidden = false
        } else if (textField == timeTextField) {
            datePicker.isHidden = false
        } else if (textField == categoryTextField) {
            categoryPicker.isHidden = false
        }
    }

    
    func configureViewComponents() {
        tabBarItem.title = "Create Event"
        view.backgroundColor = UIColor.mainBlue()
        navigationController?.navigationBar.isHidden = false
        
        view.addSubview(categoryContainerView)
        categoryContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        categoryTextField.inputView = UIView()
        
        view.addSubview(nameContainerView)
        nameContainerView.anchor(top: categoryContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        nameTextField.returnKeyType = UIReturnKeyType.done
        nameTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        view.addSubview(timeContainerView)
        timeContainerView.anchor(top: nameContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        timeTextField.inputView = UIView()
        
        view.addSubview(locationContainerView)
        locationContainerView.anchor(top: timeContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        locationTextField.inputView = UIView()
        
        view.addSubview(skillContainerView)
        skillContainerView.anchor(top: locationContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        skillTextField.inputView = UIView()
        
        view.addSubview(loginButton)
        loginButton.anchor(top: skillContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
    }
}


