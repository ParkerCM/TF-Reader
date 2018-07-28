//
//  CustomTableViewCell.swift
//  TF Reader
//
//  Created by Parker Madel on 3/12/17.
//  Copyright © 2017 Parker Madel. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var Shield: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = UIColor(white: 1.00, alpha: 1.00)
        dateLabel.textColor = UIColor(white: 1.00, alpha: 1.00)
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        //backgroundImage.image = #imageLiteral(resourceName: "keyboard")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isNotLoaded() -> Void {
        activityIndicator.startAnimating()
        Shield.isHidden = false
    }
    
    func isLoaded() -> Void{
        activityIndicator.stopAnimating()
        Shield.isHidden = true
    }

}
