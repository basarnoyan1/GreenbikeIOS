//
//  RankViewCell.swift
//  Greenbike
//
//  Created by zafer on 19.08.2018.
//  Copyright © 2018 evall.io. All rights reserved.
//

import UIKit

class RankViewCell: UITableViewCell {

    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dist: UILabel!
    @IBOutlet weak var tree: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var carbo: UILabel!
    @IBOutlet weak var energy: UILabel!
    @IBOutlet weak var speed: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
