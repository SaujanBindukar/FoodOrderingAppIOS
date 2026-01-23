//
//  UserCreateOrderViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 23/01/2026.
//

import UIKit

class UserCreateOrderViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
   
    

    @IBOutlet weak var tableNumber: UITextField!
    @IBOutlet weak var diningOptionSegment: UISegmentedControl!
    @IBOutlet weak var customerName: UITextField!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // Dishes grouped by type
    var entryDishes: [Dish] = []
    var mainDishes: [Dish] = []
    var drinkDishes: [Dish] = []
    
    let db = DatabaseManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 135
        fetchData()
    }
    
    
    var selectedDishes: [Dish: Int] = [:]
    
    // MARK: - Fetch Data
    func fetchData() {
        let allDishes = db.fetchDishes()
        // Group dishes by type
        entryDishes = allDishes.filter { $0.type == "Entry" }
        mainDishes  = allDishes.filter { $0.type == "Main" }
        drinkDishes = allDishes.filter { $0.type == "Drinks" }
        tableView.reloadData()
    }
    
    // MARK: - TableView Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "ENTRY"
        case 1: return "MAIN"
        case 2: return "DRINK"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return entryDishes.count
        case 1: return mainDishes.count
        case 2: return drinkDishes.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "userOrderViewCell",
            for: indexPath
        ) as! UserOrderViewCell
        
        let dish = dishFor(indexPath: indexPath)
        
        cell.dishName.text = dish.name
        cell.dishPrice.text = "$\(dish.price)"
        
        if let imageData = dish.image {
            cell.dishImage.image = UIImage(data: imageData)
        } else {
            cell.dishImage.image = UIImage(systemName: "photo")
        }
        
        // Show quantity
            let quantity = selectedDishes[dish] ?? 0
            cell.quantityLabel.text = "\(quantity)"
            
            // Buttons
            cell.plusButton.tag = indexPath.section * 1000 + indexPath.row
            cell.plusButton.addTarget(self, action: #selector(increaseQuantity(_:)), for: .touchUpInside)
            
            cell.minusButton.tag = indexPath.section * 1000 + indexPath.row
            cell.minusButton.addTarget(self, action: #selector(decreaseQuantity(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func increaseQuantity(_ sender: UIButton) {
        let dish = dishFor(tag: sender.tag)
        selectedDishes[dish] = (selectedDishes[dish] ?? 0) + 1
        tableView.reloadData() // update the quantity label
        updateTotalPrice()
    }
    
    func updateTotalPrice() {
        let total = selectedDishes.reduce(0) { $0 + ($1.key.price * Double($1.value)) }
        var totalPrice = String(format: "%.2f", total)
        for (dish, quantity) in selectedDishes {
            print("Dish: \(dish.name ?? ""), Quantity: \(quantity)")
        }
        totalPriceLabel.text = "\(totalPrice)"
    }


    @objc func decreaseQuantity(_ sender: UIButton) {
        let dish = dishFor(tag: sender.tag)
        if let quantity = selectedDishes[dish], quantity > 1 {
            selectedDishes[dish] = quantity - 1
        } else {
            selectedDishes.removeValue(forKey: dish)
        }
        tableView.reloadData()
        updateTotalPrice()
    }

    func dishFor(tag: Int) -> Dish {
        let section = tag / 1000
        let row = tag % 1000
        switch section {
        case 0: return entryDishes[row]
        case 1: return mainDishes[row]
        case 2: return drinkDishes[row]
        default: fatalError("Invalid tag")
        }
    }

    // MARK: - Helper
    func dishFor(indexPath: IndexPath) -> Dish {
        switch indexPath.section {
        case 0: return entryDishes[indexPath.row]
        case 1: return mainDishes[indexPath.row]
        case 2: return drinkDishes[indexPath.row]
        default: fatalError("Invalid section")
        }
    }
    
    
    @IBAction func submitOrderButton(_ sender: Any) {
        // 1️⃣ Check if at least one dish is selected
          guard !selectedDishes.isEmpty else {
              print("⚠️ No dishes selected")
              return
          }
          
          // 2️⃣ Get order info
          let customer = customerName.text
          let table = tableNumber.text
          let diningOption = diningOptionSegment.titleForSegment(at: diningOptionSegment.selectedSegmentIndex) ?? "Dine In"
        
        let orderItems = selectedDishes.map { OrderItem(dish: $0.key, quantity: $0.value) }
          
          // 3️⃣ Save order using DatabaseManager
        
        db.addOrder(customerName: customer, tableNumber: table, diningOption: diningOption, selectedItems: orderItems)
         
          
          // 4️⃣ Optional: Print order summary
          print("✅ Order Submitted!")
          print("Customer: \(customer ?? "N/A")")
          print("Table: \(table ?? "N/A")")
          print("Dining Option: \(diningOption)")
          print("Dishes:")
          
          var total: Double = 0
          for (dish, quantity) in selectedDishes {
              print("\(dish.id?.uuidString ?? "") - \(dish.name ?? "") x\(quantity) - $\(dish.price * Double(quantity))")
              total += dish.price * Double(quantity)
          }
          print("Total Price: $\(String(format: "%.2f", total))")
          
          // 5️⃣ Reset UI for next order
          selectedDishes.removeAll()
          tableView.reloadData()
          updateTotalPrice()
          customerName.text = ""
          tableNumber.text = ""
    }
    
    

}
