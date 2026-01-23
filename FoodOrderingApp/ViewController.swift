//
//  ViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailController: UITextField!
    @IBOutlet weak var passwordController: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let username = emailController.text ?? ""
        let password = passwordController.text ?? ""
        
        if username == "admin" && password == "admin123" {
            navigateToAdminHome()
        } else if username == "user" && password == "user123" {
            navigateToUserHome()
        } else {
            let alert = UIAlertController(title: "Error", message: "Invalid credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func navigateToAdminHome(){
        // Get storyboard
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
           // Instantiate AdminTabBarController
           if let adminTabBar = storyboard.instantiateViewController(withIdentifier: "AdminTabController") as? UITabBarController {
               // Make it the root view controller
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate {
                   sceneDelegate.window?.rootViewController = adminTabBar
               }
           }
        
    }
    
    func navigateToUserHome(){
        
        // Get storyboard
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
           // Instantiate AdminTabBarController
           if let userTabBar = storyboard.instantiateViewController(withIdentifier: "UserTabController") as? UITabBarController {
               // Make it the root view controller
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate {
                   sceneDelegate.window?.rootViewController = userTabBar
               }
           }
        
        
    }
    
}

