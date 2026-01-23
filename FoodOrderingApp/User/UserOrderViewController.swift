//
//  UserOrderViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 23/01/2026.
//

import UIKit

class UserOrderViewController: UIViewController {

    // Array to store fetched orders
      var orders: [Order] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchOrder()
       
    }

    

      override func viewDidLoad() {
          super.viewDidLoad()

          // Fetch orders when the view loads
          fetchOrder()
      }

      func fetchOrder() {
          let db = DatabaseManager()
          self.orders = db.fetchOrders() // fetchOrders() from your DatabaseManager

          print("Fetched \(orders.count) orders")
          
          for order in orders {
              print("Order ID:", order.id ?? UUID())
              print("Customer:", order.customerName ?? "")
              print("Table:", order.tableNumber ?? "")
              print("Dining Option:", order.diningOption ?? "")
              print("Status:", order.status ?? "")
              print("Total Price:", order.totalPrice)

              let items = db.orderItems(from: order)
              for item in items {
                  print("\(item.dish.id?.uuidString ?? "") - \(item.dish.name ?? "") x\(item.quantity) - $\(item.dish.price * Double(item.quantity))")
              }
          }

         

//           TODO: reload your tableView or collectionView here if you want to show the orders in the UI
//           tableView.reloadData()
      }

}
