//
//  LoginVC.swift
//  MyFBAlbums
//
//  Created by Home on 30/10/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SCLAlertView
import MBProgressHUD

class LoginVC: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            performSegue(withIdentifier: "loggedInSegue", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    @IBAction func facebookLoginButtonPressed(sender: UIButton!) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        let facebookLoginManager = FBSDKLoginManager()
        facebookLoginManager.logIn(withReadPermissions: ["email"], from: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: Error!) -> Void in
            // If there is no error logging into facebook, get the accessToken string
            if facebookError != nil {
                progressHUD.hide(animated: true)
                SCLAlertView().showError("Facebook login failed", subTitle: facebookError!.localizedDescription)
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
//                print("Successfully logged into Facebook with accessToken: \(String(describing: accessToken))")
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken!)
                // Authenticate the facebook user to access the firebase app data
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        progressHUD.hide(animated: true)
                        SCLAlertView().showError("Facebook login failed", subTitle: error.localizedDescription)
                        return
                    }
//                    print("Successful login with AuthData: \(String(describing: user))")
                    UserDefaults.standard.set(user!.uid, forKey: KEY_UID)
                    // Segue to Logged view
                    self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                    progressHUD.hide(animated: true)
                }
            }
        }
    }
    
    @IBAction func emailLoginSignupButtonPressed(sender: UIButton!) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        if let email = emailTextField.text , email != "", let password = passwordTextField.text , password != "" {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
                if error != nil {
                    if error?._code == INVALID_USER {
                        // If the user does not exsist. Creat a new user account.
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
                            if error != nil {
                                progressHUD.hide(animated: true)
                                SCLAlertView().showError("Could Not Create Account", subTitle: "There was a problem creating a new user account.")
                            } else {
                                UserDefaults.standard.setValue(user?.uid, forKey: KEY_UID)
                                Auth.auth().signIn(withEmail: email, password: password, completion: nil)
                                self.performSegue(withIdentifier: "loggedInEmailSegue", sender: nil)
                                progressHUD.hide(animated: true)
                            }
                        })
                    } else if error?._code == INVALID_PASSWORD {
                        // If the user does exsist but the password is incorrect
                        SCLAlertView().showError("Login Failed", subTitle: "The username or password is incorrect.")
                        progressHUD.hide(animated: true)
                    } else {
                        // If there was some other error preventing the user from logging in
                        SCLAlertView().showError("Unknown Error", subTitle: error!.localizedDescription)
                        progressHUD.hide(animated: true)
                    }
                } else {
                    // If the user does exist and the password is correct, log the user in.
                    UserDefaults.standard.setValue(user?.uid, forKey: KEY_UID)
                    Auth.auth().signIn(withEmail: email, password: password, completion: nil)
                    Auth.auth().fetchProviders(forEmail: email, completion: { (provider, error) in
                        if provider!.description == "facebook.com" {
                            self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                            progressHUD.hide(animated: true)
                        } else {
                            self.performSegue(withIdentifier: "loggedInEmailSegue", sender: nil)
                            progressHUD.hide(animated: true)
                        }
                    })
                }
            })
        } else {
            progressHUD.hide(animated: true)
            SCLAlertView().showError("Email and Password Required", subTitle: "You must enter an email and a password.")
        }
    }
}
