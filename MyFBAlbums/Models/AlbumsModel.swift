//
//  AlbumsModel.swift
//  MyFBAlbums
//
//  Created by Home on 02/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit

class AlbumsModel {
    // MARK: - Var
    var name: String?
    var count: Int?
    var coverUrl: URL?
    var albumId: String?
    var photos: [ImagesModel] = []
    
    // MARK: - Init
    init(name: String, count: Int? = nil, coverUrl: URL? = nil, albmId: String) {
        self.name = name
        self.albumId = albmId
        self.coverUrl = coverUrl
        self.count = count
    }
}
