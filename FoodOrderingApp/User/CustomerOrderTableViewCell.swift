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
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
        
        // Closures for button actions
        var onDoneTapped: (() -> Void)?
        var onDeleteTapped: (() -> Void)?
        
        @IBAction func doneButtonTapped(_ sender: UIButton) {
            onDoneTapped?()
        }
        
        @IBAction func deleteButtonTapped(_ sender: UIButton) {
            onDeleteTapped?()
        }
    

    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        
        // Make sure buttons are interactive
              doneButton.isUserInteractionEnabled = true
              deleteButton.isUserInteractionEnabled = true

              // Connect buttons to closures
              doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
              deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func doneTapped() {
           onDoneTapped?()
       }

       @objc func deleteTapped() {
           onDeleteTapped?()
       }
    
    

}
