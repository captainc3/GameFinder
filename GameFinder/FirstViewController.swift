//
//  FirstViewController.swift
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController {
    
    
    // MARK: - Properties
    
    //Sign out Button
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Done Already? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "SignOut", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        return button
    }()
    
    var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUserAndConfigureView()
    }
    
    // MARK: - Selectors
    
    @objc func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            self.welcomeLabel.text = "Welcome, \(username)"
            
            UIView.animate(withDuration: 0.5, animations: {
                self.welcomeLabel.alpha = 1
            })
        }
    }
    
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
    
        
        tabBarItem.title = "Home"
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 200)
        
        view.addSubview(welcomeLabel)
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }


}

