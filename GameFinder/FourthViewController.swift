//
//  FourthViewController.swift
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import SimpleCheckbox
import Firebase

class FourthViewController: UIViewController {
    var subscriptions = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 30))
        title.textAlignment = .center
        title.text = "Subscriptions"
        title.center.x = view.center.x
        view.addSubview(title)
        addCheckboxSubviews()
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

}
