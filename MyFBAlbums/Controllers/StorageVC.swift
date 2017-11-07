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
import SCLAlertView

class StorageVC: UITableViewController {
    //MARK: - Vars
    fileprivate var progressHUD = MBProgressHUD()
    fileprivate let storageRef = Storage.storage().reference()
    fileprivate let databaseRef = Database.database().reference()
    fileprivate var albums: [[UIImage]] = []
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
        
        self.navigationController?.title = "My Storage"
        
        downloadImages()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            SCLAlertView().showError("Saving images failed", subTitle: error.localizedDescription, closeButtonTitle: "Ok")
        } else {
            SCLAlertView().showSuccess("Images saved successfully", subTitle: "Your images has been saved to your photos.", closeButtonTitle: "Ok")
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCellId", for: indexPath) as! AlbumsTableViewCell
        let albumName = self.albumsData.allKeys[indexPath.row] as! String
        cell.albumTitleLabel.text = albumName
        let albumCover = (self.albumsData[albumName] as! NSDictionary)["albumCover"] as! String
        cell.albumCoverImageView.image = getImageFromUrl(url: URL(string: albumCover)!)
        
        return cell
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
            for image in self.albums[indexPath.row] {
                self.progressHUD.show(animated: true)
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        })
        saveAction.backgroundColor = BLUE_COLOR
        
        return [deleteAction, saveAction]
    }
    
    // MARK: - Actions
    fileprivate func downloadImages() {
        let currentUser = Auth.auth().currentUser
        self.databaseRef.child("users").child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let albumsData = snapshot.value as? NSDictionary {
                self.albumsData = albumsData
                let albumNames = self.albumsData.allKeys as! [String]
                for i in 0...albumNames.count - 1 {
                    let albumData = self.albumsData[albumNames[i]] as! NSDictionary
                    let albumUrls = albumData["urls"] as! NSDictionary
                    var album = [UIImage]()
                    for url in albumUrls {
                        let image = getImageFromUrl(url: URL(string: url.value as! String)!)
                        album.append(image)
                    }
                    self.albums.append(album)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

