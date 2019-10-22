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

class SubscriptionsController: UIViewController {
    var subscriptions = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 30))
        title.textAlignment = .center
        title.text = "Subscriptions"
        title.center.x = view.center.x
        view.addSubview(title)
        addCheckboxSubviews()
        authenticateUserAndConfigureView()
    }
    
    func addCheckboxSubviews() {
        let xLoc = 50
        var yLoc = 160
    
        Database.database().reference().child("game_types").observeSingleEvent(of: .value, with: {
            snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let tickBox = Checkbox(frame: CGRect(x: xLoc, y: yLoc, width: 25, height: 25))
                let label = UILabel(frame: CGRect(x: xLoc + 40, y: yLoc, width: 200, height: 21))
                label.text = snap.value as! String?
                self.subscriptions[snap.value as! String] = false
                tickBox.accessibilityIdentifier = label.text
                tickBox.borderStyle = .square
                tickBox.checkmarkStyle = .tick
                tickBox.checkmarkSize = 0.7
                tickBox.addTarget(self, action: #selector(self.checkboxValueChanged(sender:)), for: .valueChanged)
                self.view.addSubview(tickBox)
                self.view.addSubview(label)
                yLoc += 35
            }

        })
    }

    @objc func checkboxValueChanged(sender: Checkbox) {
        subscriptions[sender.accessibilityIdentifier!] = sender.isChecked
        print(subscriptions)
    }
    
    // MARK: - Properties
    
    //Sign out Button
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Done Subscribing? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Finsh", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        return button
    }()
    
    let subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    
    // MARK: - Init
    
    // MARK: - Selectors
    
    @objc func handleSignUp() {
        
    }
    
    
    // MARK: - API
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "navcontrol") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
        } catch let error {
            print("Failed to sign out with error..", error)
        }
    }
    
    func authenticateUserAndConfigureView() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "navcontrol") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        } else {
            configureViewComponents()
            loadUserData()
        }
    }
    
    
    
    // MARK: - Helper Functions
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainBlue()
        
        tabBarItem.title = "Misc"
        
        view.addSubview(doneButton)
        doneButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 200)
        
    }

}
