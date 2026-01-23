//
//  CustomerOrderTableViewCell.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 23/01/2026.
//

import UIKit

class CustomerOrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var orderType: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var dishList: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var orderTime: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
