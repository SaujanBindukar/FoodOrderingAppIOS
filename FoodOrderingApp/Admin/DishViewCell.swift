//
//  DishViewCell.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit

class DishViewCell: UITableViewCell {
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
