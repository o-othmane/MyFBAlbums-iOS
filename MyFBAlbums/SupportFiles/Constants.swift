//
//  Constant.swift
//  MyFBAlbums
//
//  Created by Home on 02/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import Foundation
import UIKit

//// Firebase
let FIREBASE_APP_DOMAIN_BASE = "https://my-fb-albums.firebaseapp.com/__/auth/handler"
// Key
let FIREBASE_KEY_UID = "AIzaSyCGCr3PVX6IV2a4Q30upY15qSXgZ5uhYcM"
// Errors
let INVALID_USER = -8
let INVALID_PASSWORD = -6

//// Facebook

// Errors
enum LOGIN_ERROR: Error {
    case loginFailed
    case loginCancelled
    case permissionDenied
}

//// Colors
let BLUE_COLOR = UIColor.init(hex: "#3B5998")
let WHITE_COLOR = UIColor.init(hex: "#FFFFFF")
let ORANGE_COLOR = UIColor.init(hex: "#F19B2C")
let RED_COLOR = UIColor.init(hex: "#DB3A34")

//// Number of images on Row
let IMAGE_ROW = CGFloat(3)
