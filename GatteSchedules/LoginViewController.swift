//
//  LoginViewController.swift
//  GatteSchedules
//
//  Created by Colby Gatte on 11/28/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

// make sure anytime the login views are exited, the auth listener is started

import UIKit

class LoginViewController: UIViewController {
    var loggedInFromFirstTimeLogin: Bool = false

    var fontSize: CGFloat = 16.0
    
    @IBOutlet weak var logoContainerView: UIView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var loginButtonImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    // is this a good solution?
    override func viewWillAppear(_: Bool) {
        if loggedInFromFirstTimeLogin {
            loggedInFromFirstTimeLogin = false
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DB.stopAuthListener() // stop in case it's the user's first login, because we need to make the user in user branch if it is there first login and the auth listener needs to get this data

        logoContainerView.backgroundColor = UIColor.hexString(hex: "91A7B3")
        view.backgroundColor = UIColor.hexString(hex: "E3E3E3")

        let tapEndEditing = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapEndEditing)

        let loginButtonTap = UILongPressGestureRecognizer(target: self, action: #selector(loginButtonTapped(recognizer:)))
        loginButtonImageView.addGestureRecognizer(loginButtonTap)
        loginButtonTap.minimumPressDuration = 0
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func loginButtonTapped(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            print("began")
            loginButtonImageView.image = UIImage(named: "login_button_pressed.png")
        } else if recognizer.state == .ended {
            loginButtonImageView.image = UIImage(named: "login_button.png")

            let username = usernameTextField.text!
            let password = passwordTextField.text!

            DB.signIn(username: username, password: password) { _, error in
                if error == nil {
                    DB.startAuthListener() // the auth listener starts the app (it calls MainViewController.begin())
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(error.debugDescription)
                }
            }
        }
    }

    @IBAction func createTeamButtonPressed(_: Any) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        (segue.destination as? HasFirstTimeLoginDelegate)?.setDelegate(self)
    }
}

extension LoginViewController: FirstTimeLoginDelegate {
    func firstTimeLoginSuccess(user _: GSUser) {
        DB.startAuthListener()
        loggedInFromFirstTimeLogin = true
    }
}
