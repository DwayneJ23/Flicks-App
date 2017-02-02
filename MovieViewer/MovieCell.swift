//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Dwayne Johnson on 1/29/17.
//  Copyright © 2017 Dwayne Johnson. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
