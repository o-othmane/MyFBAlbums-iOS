//
//  FacebookManager.swift
//  MyFBAlbums
//
//  Created by Home on 02/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import MBProgressHUD

class FacebookManager {
    static let shared = FacebookManager()
    
    // MARK: - Var
    fileprivate var albumList: [AlbumsModel] = []
    fileprivate var pictureUrl = "https://graph.facebook.com/%@/picture?type=small&access_token=%@"
    static let idTaggedPhotosAlbum = "idPhotosOfYouTagged"
    fileprivate var profilePictureUrl: String?
    
    // MARK: - Login
    func login(controller: UIViewController, completion: @escaping (Bool, LOGIN_ERROR?) -> Void) {
        self.albumList = []
        if FBSDKAccessToken.current() == nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withReadPermissions: ["user_photos"],from: controller) { [weak self] (response, error) in
                guard let selfStrong = self else { return }
                if error != nil {
                    completion(false, .loginFailed)
                } else {
                    if response?.isCancelled == true {
                        completion(false, .loginCancelled)
                    } else {
                        if response?.token != nil {
                            if let permission = response?.declinedPermissions {
                                if permission.contains("user_photos") {
                                    selfStrong.logout()
                                    completion(false, .permissionDenied)
                                } else {
                                    completion(true, nil)
                                }
                            } else {
                                completion(false, .loginFailed)
                            }
                            
                        } else {
                            completion(false, .loginFailed)
                        }
                    }
                }
            }
        } else {
            if FBSDKAccessToken.current().permissions.contains("user_photos") {
                self.fbAlbumRequest()
                completion(true, nil)
            } else {
                self.logout()
                completion(false, .permissionDenied)
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        FBSDKLoginManager().logOut()
    }
    
    // MARK: - Profile image
    func getProfileImage(_ completion: @escaping ((Bool, String?) -> Void)) {
        if let profilUrl = self.profilePictureUrl {
            completion(true, profilUrl)
        } else {
            if FBSDKAccessToken.current() != nil {
                let param = ["fields": "picture.width(600).height(600)"]
                let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: param)
                _ = graphRequest?.start(completionHandler: { (_, result, error) -> Void in
                    if error != nil {
                        print("Error")
                        completion(false, nil)
                    } else {
                        if let result = result as? [String: AnyObject] {
                            if result["picture"] != nil {
                                if let FBpictureData = result["picture"] as? [String: AnyObject],
                                    let FBpicData = FBpictureData["data"] as? [String: AnyObject],
                                    let FBPicUrl = FBpicData["url"] as? String {
                                    self.profilePictureUrl = FBPicUrl
                                    completion(true, FBPicUrl)
                                }
                            }
                        }
                        
                        completion(false, nil)
                    }
                })
            } else {
                // KO
                completion(false, nil)
                print("Token error")
            }
        }
    }
    
    // MARK: - Albums
    func fbAlbumRequest(after: String? = nil) {
        var  path = "me/albums?fields=id,name,count,cover_photo"
        if let afterPath = after {
            path = path.appendingFormat("&after=%@", afterPath)
        }
        let graphRequest = FBSDKGraphRequest(graphPath: path, parameters: nil)
        _ = graphRequest?.start { [weak self] _, result, error in
            guard let selfStrong = self else { return }
            if error != nil {
                print(error.debugDescription)
                return
            } else {
                if let fbResult = result as? [String: AnyObject] {
                    selfStrong.parseFbAlbumResult(fbResult: fbResult)
                    if let paging = fbResult["paging"] as? [String: AnyObject],
                        paging["next"] != nil,
                        let cursors = paging["cursors"] as? [String: AnyObject],
                        let after = cursors["after"] as? String {
                        selfStrong.fbAlbumRequest(after: after)
                    } else {
                        print("Found \(selfStrong.albumList.count) album(s) with this Facebook account.")
                        NotificationCenter.default.post(name: Notification.Name.didRetrieveAlbum, object: selfStrong.albumList)
                    }
                }
            }
        }
    }
    
    fileprivate func parseFbAlbumResult(fbResult: [String: AnyObject]) {
        if let albumArray = fbResult["data"] as? [AnyObject] {
            for album in albumArray {
                if let albumDic = album as? [String:AnyObject],
                    let albumName = albumDic["name"] as? String,
                    let albumId = albumDic["id"] as? String,
                    let albumCount = albumDic["count"] as? Int {
                    let albumUrlPath = String(format : self.pictureUrl, albumId, FBSDKAccessToken.current().tokenString)
                    if let coverUrl = URL(string: albumUrlPath) {
                        let albm = AlbumsModel(name: albumName, count: albumCount, coverUrl: coverUrl, albmId: albumId)
                        self.albumList.append(albm)
                    }
                }
            }
        }
    }
    
    // MARK: - Album Images
    func fbAlbumsImageRequest(after: String?, album: AlbumsModel) {
        guard let id = album.albumId else {
            return
        }
        var path = id == FacebookManager.idTaggedPhotosAlbum
            ? "/me/photos?fields=picture,source,id"
            : "/\(id)/photos?fields=picture,source,id"
        if let afterPath = after {
            path = path.appendingFormat("&after=%@", afterPath)
        }
        let graphRequest = FBSDKGraphRequest(graphPath: path, parameters: nil)
        _ = graphRequest?.start { [weak self] _, result, error in
            guard let selfStrong = self else { return }
            if error != nil {
                print(error.debugDescription)
                return
            } else {
                if let fbResult = result as? [String: AnyObject] {
                    selfStrong.parseFbImage(fbResult: fbResult,
                                              album: album)
                if let paging = fbResult["paging"] as? [String: AnyObject],
                        paging["next"] != nil,
                        let cursors = paging["cursors"] as? [String: AnyObject],
                        let after = cursors["after"] as? String {
                        selfStrong.fbAlbumsImageRequest(after: after, album: album)
                } else {
                        print("Found \(album.photos.count) photos for the \"\(album.name!)\" album.")
                        NotificationCenter.default.post(name: Notification.Name.didRetriveAlbumImage, object: album)
                    }
                }
            }
        }
    }

    fileprivate func parseFbImage(fbResult: [String: AnyObject], album: AlbumsModel) {
        if let photosResult = fbResult["data"] as? [AnyObject] {
            for photo in photosResult {
                if let photoDic = photo as? [String : AnyObject],
                    let id = photoDic["id"] as? String,
                    let picture = photoDic["picture"] as? String,
                    let source = photoDic["source"] as? String {
                    let photoObject = ImagesModel.init(fullSizeUrl: source, normalSizeUrl: picture, imgId: id)
                    album.photos.append(photoObject)
                }
            }
        }
    }
    
    /// Reset manager
    func reset() {
        self.profilePictureUrl = nil
    }
}

