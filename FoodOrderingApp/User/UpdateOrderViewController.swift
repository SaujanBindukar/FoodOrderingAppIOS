//
//  UpdateOrderViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 24/01/2026.
//

import UIKit

class UpdateOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    var order: Order?
    
    var selectedDishes: [UUID: (dish: Dish, quantity: Int)] = [:]

    let db = DatabaseManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableNumber: UITextField!
    @IBOutlet weak var diningOption: UISegmentedControl!
    @IBOutlet weak var customerName: UITextField!
    @IBOutlet weak var totalPrice: UILabel!
    
    // Dishes grouped by type
       var entryDishes: [Dish] = []
       var mainDishes: [Dish] = []
       var drinkDishes: [Dish] = []
    override func viewDidLoad() {
         super.viewDidLoad()
         
         tableView.rowHeight = 135
         tableView.delegate = self
         tableView.dataSource = self
         
         fetchData()
         prefillOrder()
     }
    func prefillOrder() {
           guard let order = order else { return }

           customerName.text = order.customerName
           tableNumber.text = order.tableNumber
           diningOption.selectedSegmentIndex = (order.diningOption == "DineIn") ? 0 : 1

           // Prefill selected dishes
        let items = db.orderItems(from: order)
        selectedDishes.removeAll()
        for item in items {
            if let id = item.dish.id {
                selectedDishes[id] = (dish: item.dish, quantity: item.quantity)
            }
        }
           tableView.reloadData()
           updateTotalPrice()
       }
    
    // MARK: - Fetch dishes from DB
       func fetchData() {
           let allDishes = db.fetchDishes()
           entryDishes = allDishes.filter { $0.type == "Entry" }
           mainDishes = allDishes.filter { $0.type == "Main" }
           drinkDishes = allDishes.filter { $0.type == "Drinks" }
           tableView.reloadData()
       }

       // MARK: - TableView Datasource
       func numberOfSections(in tableView: UITableView) -> Int { return 3 }
       
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

            let cell = tableView.dequeueReusableCell(withIdentifier: "userOrderViewCell", for: indexPath) as! UserOrderViewCell
            let dish = dishFor(indexPath: indexPath)
            
            cell.dishName.text = dish.name
            cell.dishPrice.text = "$\(dish.price)"
            cell.dishImage.image = dish.image != nil ? UIImage(data: dish.image!) : UIImage(systemName: "photo")
        let quantity = selectedDishes[dish.id ?? UUID()]?.quantity ?? 0
        cell.quantityLabel.text = "\(quantity)"
            
            cell.plusButton.tag = indexPath.section * 1000 + indexPath.row
            cell.plusButton.addTarget(self, action: #selector(increaseQuantity(_:)), for: .touchUpInside)
            
            cell.minusButton.tag = indexPath.section * 1000 + indexPath.row
            cell.minusButton.addTarget(self, action: #selector(decreaseQuantity(_:)), for: .touchUpInside)

            return cell
        }
    @objc func increaseQuantity(_ sender: UIButton) {
        let dish = dishFor(tag: sender.tag)
            guard let id = dish.id else { return }

            if let existing = selectedDishes[id] {
                selectedDishes[id] = (dish: dish, quantity: existing.quantity + 1)
            } else {
                selectedDishes[id] = (dish: dish, quantity: 1)
            }

            tableView.reloadData()
            updateTotalPrice()
        }
        
        @objc func decreaseQuantity(_ sender: UIButton) {
            let dish = dishFor(tag: sender.tag)
                guard let id = dish.id else { return }

                if let existing = selectedDishes[id] {
                    if existing.quantity > 1 {
                        selectedDishes[id] = (dish: dish, quantity: existing.quantity - 1)
                    } else {
                        selectedDishes.removeValue(forKey: id)
                    }
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

        func dishFor(indexPath: IndexPath) -> Dish {
            switch indexPath.section {
            case 0: return entryDishes[indexPath.row]
            case 1: return mainDishes[indexPath.row]
            case 2: return drinkDishes[indexPath.row]
            default: fatalError("Invalid section")
            }
        }
        
        func updateTotalPrice() {
            let total = selectedDishes.reduce(0) { $0 + ($1.value.dish.price * Double($1.value.quantity)) }
            totalPrice.text = String(format: "%.2f", total)
        }


    @IBAction func updateOrderButton(_ sender: Any) {

        guard let order = order else { return }
          guard !selectedDishes.isEmpty else {
              print("⚠️ No dishes selected")
              return
          }

          let customer = customerName.text
          let table = tableNumber.text
          let dining = diningOption.titleForSegment(at: diningOption.selectedSegmentIndex) ?? "DineIn"

          // Map dictionary to [OrderItem]
          let orderItems = selectedDishes.map { (_, value) in
              OrderItem(dish: value.dish, quantity: value.quantity)
          }

          db.updateOrder(orderID: order.id!,
                         customerName: customer,
                         tableNumber: table,
                         diningOption: dining,
                         selectedItems: orderItems,
                         status: "Pending")

          print("✅ Order updated successfully!")
          navigationController?.popViewController(animated: true)
    }
    @IBAction func diningOptionChanged(_ sender: Any) {}
    
    @IBAction func deleteOrderButtonPressed(_ sender: Any) {
        guard let order = order else { return }
        let alert = UIAlertController(
            title: "Delete Order",
            message: "Are you sure you want to delete this order?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.db.deleteOrder(orderID: order.id!)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}

