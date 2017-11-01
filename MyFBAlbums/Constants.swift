
//  Constants.swift
//  Created by Jim on 24/04/2016.


import Foundation
import UIKit


//// FIREBASE_APP_DOMAIN_BASE ////
// Under your App Dashboard in Firebase. Select “User & Authentication” and under “Authorised Domains for OAuth Redirects”
// Add your domain to the FIREBASE_APP_DOMAIN_BASE constant
let FIREBASE_APP_DOMAIN_BASE = "https://my-fb-albums.firebaseapp.com/__/auth/handler"


// KEYS
let FB_KEY_UID = ""
let KEY_UID = "AIzaSyCGCr3PVX6IV2a4Q30upY15qSXgZ5uhYcM"


//// FIREBASE ERRORS ////
// Code = -8 "(Error Code: INVALID_USER) The specified user does not exist."
let INVALID_USER = -8

// Code = -6 "(Error Code: INVALID_PASSWORD) The specified password is incorrect."
let INVALID_PASSWORD = -6

// COLORS
let SHADOW_COLOR = UIColor.init(hex: "#3B5998").cgColor

