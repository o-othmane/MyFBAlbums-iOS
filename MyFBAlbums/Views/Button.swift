//
//  Button.swift
//  MyFBAlbums
//
//  Created by Home on 30/10/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit

@IBDesignable

class Button: UIButton {
    override func awakeFromNib() {
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        layer.cornerRadius = 5.0
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize.init(width: 0.0, height: 2.0)
    }
}
