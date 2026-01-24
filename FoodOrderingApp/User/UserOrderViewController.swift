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
        refreshOrders()
    }

    func refreshOrders() {
        orders = db.fetchOrders()
        tableView.reloadData()
    }
    
    
      override func viewDidLoad() {
          super.viewDidLoad()
          tableView.rowHeight = 210
          tableView.allowsMultipleSelectionDuringEditing = true
          navigationItem.rightBarButtonItem = editButtonItem
          let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
          tableView.addGestureRecognizer(longPress)

          // Fetch orders when the view loads
          fetchOrder()
      }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        // Enter editing mode and select the pressed row
        if !tableView.isEditing {
            setEditing(true, animated: true)
        }
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // Deselect any selected rows
        if let selected = tableView.indexPathsForSelectedRows {
            for indexPath in selected {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        // Exit editing mode
        setEditing(false, animated: true)
    }
    
    @objc private func cancelBarButtonTapped() {
        cancelButtonPressed(self)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        if editing {
            // Show Cancel button on the left when editing
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        } else {
            // Hide Cancel button when not editing
            navigationItem.leftBarButtonItem = nil
        }
    }

    @IBAction func deleteSelected(_ sender: Any) {
        // Ensure table is in editing mode to allow multi-selection
        if !tableView.isEditing { tableView.setEditing(true, animated: true) }
        
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return }
            
            let alert = UIAlertController(title: "Delete Orders",
                                          message: "Are you sure you want to delete selected orders?",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                // Delete selected orders
                for indexPath in selectedIndexPaths.sorted(by: { $0.row > $1.row }) {
                    let order = self.orders[indexPath.row]
                    self.db.deleteOrder(orderID: order.id!)
                }
                // Refresh table
                self.fetchOrder()
                self.tableView.setEditing(false, animated: true)
            }))
            
            present(alert, animated: true)
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
        tableView.reloadData()
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
       
        if order.status == "Done" {
            cell.doneButton.isHidden = true
        } else {
            cell.doneButton.isHidden = false
        }
        
        if order.status == "Done" {
            cell.status.textColor = .systemGreen
            cell.status.font = UIFont.boldSystemFont(ofSize: cell.status.font.pointSize)
        } else {
            cell.status.textColor = .label // default color (supports dark mode)
            cell.status.font = UIFont.systemFont(ofSize: cell.status.font.pointSize)
        }
        var allDish = ""
        let items = db.orderItems(from: order)

        for item in items {
            allDish += "\(item.dish.name ?? "") x\(item.quantity)  "
        }
        // MARK AS DONE
           cell.onDoneTapped = { [weak self] in
               self?.markOrderAsDone(order)
               self?.tableView.reloadData()
           }

           // DELETE
           cell.onDeleteTapped = { [weak self] in
               self?.deleteOrder(order)
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
    
    func markOrderAsDone(_ order: Order) {
        order.status = "Done"
        print("The order id is \(order.id)")
        db.updateOrderStatus(orderID: order.id!, status: "Done")
        refreshOrders()
    }

    func deleteOrder(_ order: Order) {
        guard let orderID = order.id else {
            print("⚠️ Order has no ID")
            return
        }
        
        let alert = UIAlertController(title: "Delete Order",
                                      message: "Are you sure you want to delete this order?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.db.deleteOrder(orderID: orderID)
            self.refreshOrders()
        }))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            // In editing mode, just select for deletion
            return
        }
        // Navigate to edit/detail page when not editing
        print("Navigting to different place")
//        let order = orders[indexPath.row]
//        if let editVC = storyboard?.instantiateViewController(withIdentifier: "EditOrderViewController") as? EditOrderViewController {
//            editVC.order = order
//            navigationController?.pushViewController(editVC, animated: true)
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            // In editing mode, just deselect for deletion
            return
        }
    }



}
