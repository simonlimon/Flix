//
//  MovieCell.swift
//  Flix
//
//  Created by Simon Posada Fishman on 6/15/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import UAProgressView

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var backView: UIView!

    
    @IBOutlet weak var circleProgressView: UAProgressView!
    
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var ratingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        circleProgressView.fillOnTouch = false
        backView.layer.cornerRadius = 10.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func imageTapped(sender: AnyObject) {
    
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            
            if (self.ratingView.alpha == 0.0) {
                self.ratingView.alpha = 1.0
            } else {
                self.ratingView.alpha = 0.0
            }
            
            }, completion: nil)
    }
    
//    //1 - the properties for the gradient
//    @IBInspectable var startColor: UIColor = UIColor.redColor()
//    @IBInspectable var midColor: UIColor = UIColor.yellowColor()
//    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    func setCircleColor(number: Double) {
        let r = number<50 ? 255 : floor(255-(number*2-100)*255/100);
        let g = number>50 ? 255 : floor((number*2)*255/100);
        
        
        let color = UIColor.init(red: CGFloat(r/255), green: CGFloat(g/255), blue: 0, alpha: 1)
        ratingView.color = color
        ratingView.setNeedsDisplay()
        circleProgressView.tintColor = color
    }
}
