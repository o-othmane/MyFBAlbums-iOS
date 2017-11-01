//
//  View.swift
//  
//
//  Created by Home on 30/10/2017.
//

import UIKit

@IBDesignable

class View: UIView {
    override func awakeFromNib() {
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        layer.cornerRadius = 5.0
        layer.shadowColor = SHADOW_COLOR
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize.init(width: 0.0, height: 2.0)
    }
}
