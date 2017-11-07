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
import MBProgressHUD

class AlbumsVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    // MARK: - Var
    fileprivate var progressHUD = MBProgressHUD()
    fileprivate let storageRef = Storage.storage().reference()
    fileprivate let databaseRef = Database.database().reference()
    fileprivate var storedAlbums = [String]()
    fileprivate var alreadyLoaded: Bool = false
    fileprivate var imageArray: [ImagesModel] = []
    fileprivate var albums: [AlbumsModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "My FB Albums"
        
        // User profile
        if let currentUser = Auth.auth().currentUser {
            self.profileNameLabel.text = currentUser.email
            Auth.auth().fetchProviders(forEmail: currentUser.email!, completion: { (provider, error) in
                if provider != nil && provider![0] == "facebook.com" {
                    FacebookManager.shared.getProfileImage({ (result, url) in
                        if result {
                            self.profileImage.image = getImageFromUrl(url: URL(string: url!)!)
                        }
                    })
                    self.profileNameLabel.text = currentUser.displayName
                }
            })
        }
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width/2
        profileImage.layer.borderColor = BLUE_COLOR.cgColor
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.masksToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self 
        
        if isUserHaveStorage() {
            self.storedAlbums = UserDefaults.standard.array(forKey: "STORED_ALBUMS") as! [String]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAlbum), name: Notification.Name.didRetrieveAlbum, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    // MARK: - Action
    func getImages(album:AlbumsModel!) {
        FacebookManager.shared.fbAlbumsImageRequest(after: nil, album: album)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveImage(_:)), name: Notification.Name.didRetriveAlbumImage, object: nil)
        
    }
    
    @objc func didReceiveAlbum(_ sender: Notification) {
        if let albums =  sender.object as? [AlbumsModel] {
            self.albums = albums
        }
    }
    
    @objc fileprivate func didReceiveImage(_ sender: Notification) {
        if let album = sender.object as? AlbumsModel {
            uploadImages(album:album)
        }
    }
    
    fileprivate func uploadImages(album:AlbumsModel) {
        imageArray = album.photos
        let currentUser = Auth.auth().currentUser
        let albumRef = self.databaseRef.child("users").child(currentUser!.uid).child(album.name!)
        var index = 0
        for image in imageArray {
            let randomName = getRandomString(length: 5)
            let path = "\(currentUser!.email!)/\(album.name!)"
            let uploadRef = self.storageRef.child("\(path)/\(randomName).jpg")
            let url = URL(string: image.fullSizeUrl!)
            let data = UIImageJPEGRepresentation(getImageFromUrl(url: url!), 1.0)
            index += 1
            uploadRef.putData(data!, metadata: nil) { (metadata, error) in
                if metadata != nil {
                    albumRef.child("urls").childByAutoId().setValue(metadata?.downloadURL()?.absoluteString)
                }
            }
        }
        albumRef.child("albumCover").setValue(album.coverUrl?.absoluteString)
        albumRef.child("imageCount").setValue(index)
        self.storedAlbums.append(album.name!)
        UserDefaults.standard.set(self.storedAlbums, forKey: "STORED_ALBUMS")
        SCLAlertView().showSuccess("Success", subTitle: "Album uploaded successfully")
        self.progressHUD.hide(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AlbumsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCoverCellId", for: indexPath) as! AlbumsTableViewCell
        let album = self.albums[indexPath.row]
        let image = getImageFromUrl(url:album.coverUrl!)
        cell.albumCoverImageView.image = image
        cell.albumTitleLabel.text = album.name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.albums.count == 0 {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imagesVC = self.storyboard?.instantiateViewController(withIdentifier: "ImagesVC") as! ImagesVC
        imagesVC.album = self.albums[indexPath.row]
        self.navigationController?.pushViewController(imagesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Store Action
        let storeAction = UITableViewRowAction(style: .default, title: "Add to\nStorage", handler: { (action, indexPath) in
            self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            let album = self.albums[indexPath.row]
            let currentUser = Auth.auth().currentUser
            self.databaseRef.child("users").child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(album.name!){
                    self.progressHUD.hide(animated: true)
                    SCLAlertView().showWarning("Album already saved", subTitle: "This album is already in your storage")
                }else{
                    if !album.photos.isEmpty {
                        self.imageArray = album.photos
                        self.uploadImages(album:album)
                    } else {
                        self.getImages(album:album)
                    }
                }
            })
        })
        storeAction.backgroundColor = ORANGE_COLOR
        return [storeAction]
    }
}

public func getImageFromUrl(url:URL) -> UIImage {
    var image = UIImage()
    do {
        let imageData = try Data(contentsOf: url)
        image = UIImage(data: imageData)!
    } catch {
        print("Error while getting image")
    }
    return image
}

public func getRandomString(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

public func isUserHaveStorage() -> Bool {
    return UserDefaults.standard.object(forKey: "STORED_ALBUMS") != nil
}
