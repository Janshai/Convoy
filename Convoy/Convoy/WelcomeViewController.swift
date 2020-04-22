//
//  WelcomeViewController.swift
//  Convoy
//
//  Created by Jack Adams on 21/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit
import FirebaseUI

class WelcomeViewController: UIViewController {

    @IBAction func clickLoginButton(_ sender: UIButton) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            return
        }
        
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]
        
        let authVC = authUI?.authViewController()
        
        present(authVC!,animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WelcomeViewController: FUIAuthDelegate {
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        
        guard error == nil else {
            print(error?.localizedDescription as Any)
            return
        }
        
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVCTabBar") as? UITabBarController

        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
}
