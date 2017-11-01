//
//  SettingsVC.swift
//  MyFBAlbums
//
//  Created by Home on 31/10/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import FBSDKLoginKit
import MBProgressHUD

class SettingsVC: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var currentEmailTextField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var fbAccountTextField: UITextField!
    @IBOutlet weak var fbAccountButton: UIButton!

    // MARK: - Var
    let currentUser = Auth.auth().currentUser
    var linked = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentUser != nil {
            Auth.auth().fetchProviders(forEmail: currentUser!.email!, completion: { (provider, error) in
                if provider != nil && provider![0] == "facebook.com" {
                    self.fbAccountTextField.text = self.currentUser!.displayName
                    self.fbAccountButton.titleLabel!.text = "Unlink Facebook account"
                    self.linked = true
                } else {
                    self.fbAccountTextField.text = ""
                    self.fbAccountTextField.placeholder = "No Facebook account linked"
                    self.fbAccountButton.titleLabel!.text = " Link Facebook account "
                    self.linked = false
                }
            })
            self.fbAccountTextField.isEnabled = false
            self.currentEmailTextField.text = currentUser!.email
        }
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    @IBAction func logOutButtonPressed(sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: KEY_UID)
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        dismiss(animated: true, completion: nil)
        progressHUD.hide(animated: true)
    }
    
    @IBAction func changeEmailButtonPressed(sender: UIButton!) {
        if currentUser != nil {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            if currentEmailTextField.text != "" && newEmailTextField.text != "" {
                if self.currentEmailTextField.text == currentUser!.email {
                    if isValidEmail(email:self.newEmailTextField.text!) {
                        Auth.auth().currentUser?.updateEmail(to: newEmailTextField.text!) { (error) in
                            if error != nil {
                                progressHUD.hide(animated: true)
                                SCLAlertView().showError("Error", subTitle: "Error while changing email address")
                            } else {
                                self.currentEmailTextField.text = self.newEmailTextField.text
                                self.newEmailTextField.text = ""
                                progressHUD.hide(animated: true)
                                SCLAlertView().showSuccess("Success", subTitle: "Email address changed successfully")
                            }
                        }
                    } else {
                        progressHUD.hide(animated: true)
                        SCLAlertView().showError("Error", subTitle: "Please enter a valid new email address")
                    }
                } else {
                    progressHUD.hide(animated: true)
                    SCLAlertView().showError("Error", subTitle: "Current email address doesn't match any account")
                }
            } else {
                progressHUD.hide(animated: true)
                SCLAlertView().showError("Error", subTitle: "Both current and new email are required")
            }
        }
    }
    
    @IBAction func changePasswordButtonPressed(sender: UIButton!) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        if currentUser != nil {
            if currentPasswordTextField.text != "" && newPasswordTextField.text != "" && confirmPasswordTextField.text != "" {
                if newPasswordTextField.text == confirmPasswordTextField.text {
                    if newPasswordTextField.text!.count >= 6 {
                        Auth.auth().currentUser?.updatePassword(to: newPasswordTextField.text!) { (error) in
                            if error != nil {
                                progressHUD.hide(animated: true)
                                SCLAlertView().showError("Error", subTitle: "Error while changing password")
                            } else {
                                self.currentPasswordTextField.text = ""
                                self.newPasswordTextField.text = ""
                                self.confirmPasswordTextField.text = ""
                                progressHUD.hide(animated: true)
                                SCLAlertView().showSuccess("Success", subTitle: "Password changed successfully")
                            }
                        }
                    } else {
                        progressHUD.hide(animated: true)
                        SCLAlertView().showError("Error", subTitle: "The password must contain 6 characters at least")
                    }
                } else {
                    progressHUD.hide(animated: true)
                    SCLAlertView().showError("Error", subTitle: "New password and confirmation dosen't match")
                }
            } else {
                progressHUD.hide(animated: true)
                SCLAlertView().showError("Error", subTitle: "Current and new password are required with confirmation")
            }
        }
    }
    
    @IBAction func fbAccountButtonPressed(sender: UIButton!) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        if linked {
            let alert = SCLAlertView()
            alert.addButton("Oui", action: {
                self.currentUser!.unlink(fromProvider: "facebook.com", completion: { (user, error) in
                    if error != nil {
                        progressHUD.hide(animated: true)
                        SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                    } else {
                        progressHUD.hide(animated: true)
                        self.fbAccountTextField.text = ""
                        self.fbAccountTextField.placeholder = "No Facebook account linked"
                        self.fbAccountButton.titleLabel!.text = " Link Facebook account "
                        self.linked = false
                        SCLAlertView().showSuccess("Success", subTitle: "Facebook account unlinked successfully")
                    }
                })
            })
            alert.showWarning("Unlink Facebook account", subTitle: "Are you sure to unlink your Facebook account")
        } else {
            let facebookLoginManager = FBSDKLoginManager()
            facebookLoginManager.logIn(withReadPermissions: ["email"], from: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: Error!) -> Void in
                if facebookError != nil {
                    progressHUD.hide(animated: true)
                    SCLAlertView().showError("Facebook login failed", subTitle: facebookError!.localizedDescription)
                } else {
                    let accessToken = FBSDKAccessToken.current().tokenString
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken!)
                    self.currentUser!.link(with: credential, completion: { (user, error) in
                        if error != nil {
                            progressHUD.hide(animated: true)
                            SCLAlertView().showError("Facebook login failed", subTitle: error!.localizedDescription)
                            return
                        } else {
                            progressHUD.hide(animated: true)
                            UserDefaults.standard.set(user!.uid, forKey: KEY_UID)
                            self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                            self.fbAccountTextField.text = self.currentUser!.displayName
                            self.fbAccountButton.titleLabel!.text = "Unlink Facebook account"
                            self.linked = true
                            SCLAlertView().showSuccess("Success", subTitle: "Facebook account linked successfully")
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func deleteAccountButtonPressed(sender: UIButton!) {
        let alert = SCLAlertView()
        alert.addButton("Oui", action: {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.currentUser!.delete(completion: { (error) in
                if error != nil {
                    progressHUD.hide(animated: true)
                    SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                } else {
                    progressHUD.hide(animated: true)
                    SCLAlertView().showSuccess("Success", subTitle: "Account deleted successfully")
                }
            })
                
            })
        alert.showWarning("Unlink Facebook account", subTitle: "Are you sure to unlink your Facebook account")
    }
}
