//
//  ImagesModel.swift
//  MyFBAlbums
//
//  Created by Home on 02/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import Foundation
import UIKit

public class ImagesModel {
    // MARK: - Var
    public var normalSizeUrl: String?
    public var fullSizeUrl: String?
    public var imageId: String?
    
    // MARK: - Init
    init(fullSizeUrl: String, normalSizeUrl: String, imgId: String) {
        self.imageId = imgId
        self.normalSizeUrl = normalSizeUrl
        self.fullSizeUrl = fullSizeUrl
    }
}
