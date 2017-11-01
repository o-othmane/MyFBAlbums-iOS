//
//  StorageVC.swift
//  MyFBAlbums
//
//  Created by Home on 01/11/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit
import Firebase

class StorageVC: UITableViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCoverCellId", for: indexPath) as! AlbumsTableViewCell
        cell.albumCoverImageView.image = UIImage(named: "DefaultAlbums")
        cell.albumTitleLabel.text = indexPath.row.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Share Action
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (action, indexPath) in
            print("Share tapped")
            
        })
        shareAction.backgroundColor = UIColor.blue
        
        // Delete Action
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            print("Delete tapped")
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [shareAction, deleteAction]
    }
}

