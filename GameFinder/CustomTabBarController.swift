//
//  CustomTabBarController.swift
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    var tabBarIteam = UITabBarItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray], for: .normal)
        
        let selectedImage1 = UIImage(named: "add_white-")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "add-")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![0]
        tabBarIteam.image = deSelectedImage1
        tabBarIteam.selectedImage = selectedImage1
        
        let selectedImage2 = UIImage(named: "alert_white-")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "alert-")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![1]
        tabBarIteam.image = deSelectedImage2
        tabBarIteam.selectedImage = selectedImage2
        
        let selectedImage3 = UIImage(named: "profile_white-")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "profile-")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![2]
        tabBarIteam.image = deSelectedImage3
        tabBarIteam.selectedImage = selectedImage3
        
//        let selectedImage4 = UIImage(named: "profile_white-")?.withRenderingMode(.alwaysOriginal)
//        let deSelectedImage4 = UIImage(named: "profile-")?.withRenderingMode(.alwaysOriginal)
//        tabBarIteam = self.tabBar.items![3]
//        tabBarIteam.image = deSelectedImage4
//        tabBarIteam.selectedImage = selectedImage4
        
        self.selectedIndex = 0
        

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIImage {
    func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
