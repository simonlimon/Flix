//
//  RatingView.swift
//  Flix
//
//  Created by Simon Posada Fishman on 6/17/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit

@IBDesignable class RatingView: UIView {

    @IBInspectable var color: UIColor = UIColor.blackColor()
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        color.setFill()
        path.fill()
    }
    

}
