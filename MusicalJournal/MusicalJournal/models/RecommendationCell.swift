//
//  RecommendationCell.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-17.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RecommendationCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
