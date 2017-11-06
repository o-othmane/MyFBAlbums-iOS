//
//  ImagesVC.swift
//  MyFBAlbums
//
//  Created by Home on 03/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImagesVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var imagesCollection: UICollectionView!
    
    // MARK: - Var
    fileprivate var cellSize: CGFloat?
    fileprivate let cellPerRow: CGFloat = IMAGE_ROW
    fileprivate var alreadyLoaded: Bool = false
    var progressHUD = MBProgressHUD()
    var album: AlbumsModel?
    fileprivate var imageArray: [ImagesModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.imagesCollection?.reloadData()
            }
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)

        self.title = self.album?.name ?? NSLocalizedString("Pictures", comment: "")

        self.imagesCollection.delegate = self
        self.imagesCollection.dataSource = self

        if let collectionWidth = self.imagesCollection?.frame.width {
            self.cellSize = (collectionWidth - 60.0) / self.cellPerRow
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveImage(_:)), name: Notification.Name.didRetriveAlbumImage, object: nil)
        
        self.getImages()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.didRetriveAlbumImage, object: nil)
    }
    
    // MARK: - Actions
    func getImages() {
        if let photosArray = self.album?.photos {
            self.imageArray = photosArray
            if imageArray.isEmpty {
                if let album = self.album {
                    FacebookManager.shared.fbAlbumsImageRequest(after: nil, album: album)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveImage(_:)), name: Notification.Name.didRetriveAlbumImage, object: nil)
                }
            } else {
                self.progressHUD.hide(animated: true)
            }
        }
    }
    
    @objc fileprivate func didReceiveImage(_ sender: Notification) {
        self.alreadyLoaded = true
        if let album = sender.object as? AlbumsModel, self.album?.albumId == album.albumId {
            self.imageArray = album.photos
            self.progressHUD.hide(animated: true)
        }
    }
    
    fileprivate func cleanController() {
        self.alreadyLoaded = false
        self.imageArray = []
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ImagesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Empty album
        if imageArray.count <= 0, self.alreadyLoaded {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.imagesCollection?.frame.size.width ?? 0, height: self.imagesCollection?.frame.size.height ?? 0))
            emptyLabel.textAlignment = .center
            emptyLabel.text = "No picture(s) in this album."
            emptyLabel.font = UIFont.italicSystemFont(ofSize: 16)
            emptyLabel.textColor = UIColor.white
            self.imagesCollection?.backgroundView = emptyLabel
            return 0
        }
        
        // Display photos
        self.imagesCollection?.backgroundView = nil
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageModel = self.imageArray[indexPath.row]
        let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as! ImageVC
        imageVC.image = getImageFromUrl(url: URL(string: imageModel.fullSizeUrl!)!)
        self.navigationController?.pushViewController(imageVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumImageCellId", for: indexPath) as? ImagesTableViewCell
        cell!.img.image = getImageFromUrl(url: URL(string: self.imageArray[indexPath.row].normalSizeUrl!)!)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize ?? 0, height: self.cellSize ?? 0)
    }
}
