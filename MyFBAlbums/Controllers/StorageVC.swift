//
//  StorageVC.swift
//  MyFBAlbums
//
//  Created by Home on 01/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class StorageVC: UITableViewController {
    //MARK: - Vars
    fileprivate var progressHUD = MBProgressHUD()
    fileprivate let storageRef = Storage.storage().reference()
    fileprivate let databaseRef = Database.database().reference()
    fileprivate var storedAlbums = [String]()
    fileprivate var albums: [[UIImage]] = []
    fileprivate var imageArray: [UIImage] = []
    fileprivate var albumsData: NSDictionary = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImages()
//        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.navigationController?.title = "My Storage"
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCellId", for: indexPath) as! AlbumsTableViewCell
        let albumName = self.albumsData.allKeys[indexPath.row] as! String
        cell.albumTitleLabel.text = albumName
        let albumData = (self.albumsData[albumName] as! NSDictionary)["urls"] as! NSDictionary
print("\n\n",albumData[0])        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsData.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Delete Action
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            print("Delete tapped")
        })
        deleteAction.backgroundColor = RED_COLOR
        
        // Save Action
        let saveAction = UITableViewRowAction(style: .default, title: "Save to\nCamera roll", handler: { (action, indexPath) in
            print("Save tapped")
        })
        deleteAction.backgroundColor = BLUE_COLOR
        return [saveAction, deleteAction]
    }
    
    // MARK: - Actions
    fileprivate func downloadImages() {
        let currentUser = Auth.auth().currentUser
        self.databaseRef.child("users").child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.albumsData = snapshot.value as! NSDictionary
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

