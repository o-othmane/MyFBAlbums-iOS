//
//  ImagesTableViewCell.swift
//  MyFBAlbums
//
//  Created by Home on 03/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit

class ImagesTableViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var img: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        img.image = UIImage(named: "DefaultImages")
        self.backgroundColor = WHITE_COLOR
    }
}
