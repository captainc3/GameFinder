//
//  SubscriptionsController.swift
//  GameFinder
//
//  Created by Warren Waleed on 10/21/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import SimpleCheckbox
import Firebase

class SubscriptionsController: UIViewController, UITextFieldDelegate {
    var subscriptions = [String: Bool]()
    var checkboxes = [String: Checkbox]()
    var requestGameText : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = UILabel(frame: CGRect(x: 0, y: 50, width: 300, height: 30))
        title.textAlignment = .center
        title.text = "Subscriptions"
        title.center.x = view.center.x
        view.addSubview(title)
        addCheckboxSubviews()
        configureViewComponents()
        assignbackground()
    }
    
    func assignbackground(){
        let background = UIImage(named: "IMG")

        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func addCheckboxSubviews() {
        let xLoc = 50
        var yLoc = 200
        guard let uid = Auth.auth().currentUser?.uid else { return }
    
        Database.database().reference().child("game_types").observeSingleEvent(of: .value, with: {
            snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let tickBox = Checkbox(frame: CGRect(x: xLoc, y: yLoc, width: 25, height: 25))
                let label = UILabel(frame: CGRect(x: xLoc + 40, y: yLoc, width: 200, height: 21))
                label.text = snap.value as! String?
                self.checkboxes[label.text!] = tickBox
                tickBox.accessibilityIdentifier = label.text
                tickBox.borderStyle = .square
                tickBox.checkmarkStyle = .tick
                tickBox.checkmarkSize = 0.7
                tickBox.addTarget(self, action: #selector(self.checkboxValueChanged(sender:)), for: .valueChanged)
                self.view.addSubview(tickBox)
                self.view.addSubview(label)
                yLoc = yLoc + 35
            }

        })
        let submitButton = UIButton(frame: CGRect(x: xLoc + 100, y: yLoc + 330, width: 350, height: 40))
       submitButton.backgroundColor = .white
        submitButton.setTitleColor(UIColor.mainBlue(), for: .normal)
        submitButton.center.x = self.view.center.x
        submitButton.setTitle("SUBMIT SUBSCRIPTIONS", for: .normal)
        submitButton.showsTouchWhenHighlighted = true
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(updateSubscriptions), for: .touchUpInside)
        self.view.addSubview(submitButton)
        
        let doneButton = UIButton(frame: CGRect(x: xLoc + 100, y: yLoc + 390, width: 350, height: 40))
        doneButton.backgroundColor = .white
         doneButton.setTitleColor(UIColor.red, for: .normal)
         doneButton.center.x = self.view.center.x
         doneButton.setTitle("FINISH REGISTRATION", for: .normal)
         doneButton.showsTouchWhenHighlighted = true
         doneButton.layer.cornerRadius = 5
         doneButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
         self.view.addSubview(doneButton)
        Database.database().reference().child("users").child(uid).child("subscriptions").observeSingleEvent(of: .value, with: {
            snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let text = snap.key
                    self.checkboxes[text]?.isChecked = true
                    self.subscriptions[text] = true
                }
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.requestGameText.endEditing(true)
        return false
    }

    @objc func checkboxValueChanged(sender: Checkbox) {
        if (sender.isChecked) {
            subscriptions[sender.accessibilityIdentifier!] = true
        } else {
            subscriptions.removeValue(forKey: sender.accessibilityIdentifier!)
        }
    }
    
    @objc func updateSubscriptions(sender: UIButton!) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var children = [String]()
        
        let alert = UIAlertController(title: "Update subscriptions?", message: "Are you sure you want to update your subscriptions?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            if (self.subscriptions.count > 0) {
                Database.database().reference().child("users").child(uid).updateChildValues(["subscriptions": self.subscriptions])
            } else {
            Database.database().reference().child("users").child(uid).updateChildValues(["subscriptions": "none"])
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            Database.database().reference().child("users").child(uid).child("subscriptions").observeSingleEvent(of: .value, with: {
                snapshot in
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let text = snap.key
                        children.append(text)
                    }
                for (key, _) in self.checkboxes {
                    if (children.contains(key)) {
                        self.checkboxes[key]?.isChecked = true
                        self.subscriptions[key] = true
                    } else {
                        self.checkboxes[key]?.isChecked = false
                    }
                }
            })
        }))
        self.present(alert, animated: true)
        
    }

    

    
    //Sign out Button
    /*let doneButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Done? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Finish Registration", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.red]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }() */
    
    
    
    // MARK: - Init
    
    // MARK: - Selectors
    
    
    // MARK: - API
    
    @objc func handleShowLogin() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainBlue()
        
//        view.addSubview(doneButton)
//        doneButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 200)
        
    }
    
}
    // MARK: - Properties
