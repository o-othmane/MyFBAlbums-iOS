//
//  AlbumsVC.swift
//  MyFBAlbums
//
//  Created by Home on 30/10/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import SCLAlertView

class AlbumsVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User profile
        if let currentUser = Auth.auth().currentUser {
            self.profileNameLabel.text = currentUser.email
            Auth.auth().fetchProviders(forEmail: currentUser.email!, completion: { (provider, error) in
                if provider != nil && provider![0] == "facebook.com" {
                    self.profileImage.image = self.getUserProfileImage(user: currentUser)
                    self.profileNameLabel.text = currentUser.displayName
                }
            })
        }
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width/2
        profileImage.layer.borderColor = UIColor.init(hex: "#3B5998").cgColor
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.masksToBounds = true

        // TableView
        self.tableView.backgroundColor = .clear
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    // MARK: - Functions
    func getUserProfileImage(user: User) -> UIImage {
        var image = UIImage()
        do {
            let imageData = try Data(contentsOf: user.photoURL!)
            image = UIImage(data: imageData)!
        } catch {
            SCLAlertView().showError("Error", subTitle: "Error while getting profile image")
        }
        return image
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AlbumsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCoverCellId", for: indexPath) as! AlbumsTableViewCell
        cell.albumCoverImageView.image = UIImage(named: "DefaultAlbums")
        cell.albumTitleLabel.text = indexPath.row.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
