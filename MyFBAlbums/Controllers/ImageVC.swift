//
//  ImageVC.swift
//  MyFBAlbums
//
//  Created by Home on 03/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit

class ImageVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    // MARK: - Var
    var image = UIImage(named: "DefaultImage") {
        didSet {
            DispatchQueue.main.async {
                self.imageView?.reloadInputViews()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        imageView.image = image
        super.viewDidLoad()
    }
    
    // MARK: - Action
    @IBAction func shareButtonClicked(_ sender: Any) {
        if self.shareButton.title == "Select" {
            
        } else {
            self.shareButton.title = "Select"
        }
    }
}
