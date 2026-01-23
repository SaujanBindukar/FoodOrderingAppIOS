//
//  UserOrderViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 23/01/2026.
//

import UIKit

class UserOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    let db = DatabaseManager()

    // Array to store fetched orders
      var orders: [Order] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.rowHeight = 210
        fetchOrder()
       
    }
    
    
      override func viewDidLoad() {
          super.viewDidLoad()

          // Fetch orders when the view loads
          fetchOrder()
      }

      func fetchOrder() {
          
          self.orders = db.fetchOrders() // fetchOrders() from your DatabaseManager

          print("Fetched \(orders.count) orders")
          
          for order in orders {
              let items = db.orderItems(from: order)
              for item in items {
                  print(" \(item.dish.name ?? "") x\(item.quantity)")
              }
          }

         

//           TODO: reload your tableView or collectionView here if you want to show the orders in the UI
//           tableView.reloadData()
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerOrderCell", for: indexPath) as! CustomerOrderTableViewCell
        let order = orders[indexPath.row]

        cell.orderType?.text = "Table \(order.tableNumber ?? "") - \(order.diningOption ?? "")"
        cell.customerName.text = order.customerName
        cell.status.text = order.status
        cell.totalPrice.text = "$\(order.totalPrice)"
        cell.orderTime.text = minutesAgo(from:order.orderTime!)
        var allDish = ""
        let items = db.orderItems(from: order)

        for item in items {
            allDish += "\(item.dish.name ?? "") x\(item.quantity)  "
        }

        cell.dishList.text = allDish
        return cell
    }
    func minutesAgo(from date: Date) -> String {
        let minutes = Int(Date().timeIntervalSince(date) / 60)
        
        if minutes < 1 { return "Just now" }
        if minutes == 1 { return "1m ago" }
        return "\(minutes)m ago"
    }

}
