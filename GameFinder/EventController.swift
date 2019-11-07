//
//  EventController.swift
//  GameFinder
//
//  Created by Warren Waleed on 10/6/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import Firebase


class EventController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    var cellDetails:String = ""
    
    
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 120, y: self.view.frame.size.height - 385, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.5, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "logo")
        return iv
    }()
    
    
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("JOIN EVENT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(joinEvent), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't want to join this event? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Go back", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        return true
    }
    
    private func parseDate(_ str : String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM d yyyy"
        return dateFormat.date(from: str)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Selectors
    
    @objc func joinEvent() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to join this event?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Join Event", style: .destructive, handler: { (_) in
            self.join()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func join() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            Database.database().reference().child("joined_events").child(self.cellDetails).setValue([username: uid])
        }
        self.showToast(message: "Successfully joined event")
    }
    
    @objc func handleShowLogin() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    // MARK: - API
    
    
    
    // MARK: - Helper Functions
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainBlue()
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        Database.database().reference().child("events").child(cellDetails).observeSingleEvent(of: .value, with: {
            snapshot in
            
            let delimiter = " Created"
            let eventTitle = snapshot.key.components(separatedBy: delimiter)[0]
            var eventLoc = ""
            var eventSkill = ""
            var eventDate = Date()
            var eventCreator = ""
            var eventCategory = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if (snap.key == "Location of event") {
                    eventLoc = "Location: \(snap.value as! String)"
                }
                if (snap.key == "Skill") {
                    eventSkill = "Skill: \(snap.value as! String)"
                }
                if (snap.key == "Category") {
                    eventCategory = "Category: \(snap.value as! String)"
                }
                if (snap.key == "Time of event") {
                    let delimiter = " "
                    let dateString = Array((snap.value as! String).components(separatedBy: delimiter).dropFirst().dropLast().dropLast())
                    eventDate = (self.parseDate(dateString.joined(separator: " ")))
                }
                if (snap.key == "Creator") {
                    eventCreator = "Event by: \(snap.value as! String)"
                }
            }
            let df = DateFormatter()
            df.dateFormat = "E, MM/d/yy"
            let eventDateString = "Date: \(df.string(from: eventDate))"
            let eventArray = [eventTitle, eventLoc, eventSkill, eventDateString, eventCategory, eventCreator]
            let xLoc = 50
            var yLoc = 180
            for n in 0 ... 5 {
                let label = UILabel(frame: CGRect(x: xLoc + 40, y: yLoc, width: 200, height: 21))
                label.text = eventArray[n]
                label.textColor = UIColor.white
                yLoc = yLoc + 35
                self.view.addSubview(label)
            }
        })
        
        view.addSubview(loginButton)
        loginButton.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 200, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 50)
        
    }
}
