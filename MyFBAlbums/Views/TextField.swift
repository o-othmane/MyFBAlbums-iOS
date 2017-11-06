//
//  TextField.swift
//  MyFBAlbums
//
//  Created by Home on 30/10/2017.
//  Copyright © 2017 OthmaneOuenzar. All rights reserved.
//

import UIKit

@IBDesignable
class TextField: UITextField {
    override func awakeFromNib() {
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        layer.cornerRadius = 5.0
        layer.borderColor = BLUE_COLOR.cgColor
        layer.borderWidth = 1.0
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }
}
