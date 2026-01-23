//
//  DatabaseManager.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit
import CoreData

class DatabaseManager: NSObject {
    func addDish(name: String, type: String, price: Double, ingredients: String, image: UIImage){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let dish = Dish(context: context)
               dish.id = UUID()
               dish.name = name
               dish.type = type
               dish.ingredients = ingredients
               dish.price = price

               // Store image if available
               dish.image = image.jpegData(compressionQuality: 0.8)
        
        print("The uuid is \(dish.id)")
        

               do {
                   try context.save()
                   print("✅ Dish saved successfully")
               } catch {
                   print("❌ Failed to save dish:", error.localizedDescription)
               }
        
    }
    
    func updateDish(id: UUID, name: String, type: String, price: Double, ingredients: String, image: UIImage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        // Fetch the dish with the given id
        let request: NSFetchRequest<Dish> = Dish.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id as CVarArg)

        do {
            let results = try context.fetch(request)
            if let dishToUpdate = results.first {
                // Update fields
                dishToUpdate.name = name
                dishToUpdate.type = type
                dishToUpdate.price = price
                dishToUpdate.ingredients = ingredients
                dishToUpdate.image = image.jpegData(compressionQuality: 0.8)

                // Save context
                try context.save()
                print("✅ Dish updated successfully")
            } else {
                print("⚠️ Dish with id \(id) not found")
            }
        } catch {
            print("❌ Failed to update dish:", error.localizedDescription)
        }
    }

    
    func deleteDish(dish: Dish) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(dish)
        
        do {
            try context.save()
            print("Dish deleted successfully")
        } catch {
            print("Failed to delete dish: \(error)")
        }
    }

    func fetchDishes() -> [Dish] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Dish> = Dish.fetchRequest()

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Fetch failed:", error.localizedDescription)
            return []
        }
    }
    
    func addOrder(customerName: String?, tableNumber: String?, diningOption: String, selectedItems: [OrderItem]) {
        // 1. Ensure Core Data context
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // 2. Create a new Order entity
        let newOrder = Order(context: context)
        newOrder.id = UUID()
        newOrder.customerName = customerName
        newOrder.tableNumber = tableNumber
        newOrder.diningOption = diningOption
        newOrder.orderTime = Date()
        newOrder.status = "Pending"
        
        // 3. Convert selected dishes + quantities to JSON string
        let orderData: [[String: Any]] = selectedItems.map { item in
            [
                "dishID": item.dish.id?.uuidString,
                "dishName": item.dish.name ?? "",
                "price": item.dish.price,
                "quantity": item.quantity
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: orderData, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            newOrder.orderedDishes = jsonString
        } else {
            print("⚠️ Failed to encode ordered dishes")
            newOrder.orderedDishes = "[]"
        }
        
        // 4. Calculate total price
        let total = selectedItems.reduce(0) { $0 + ($1.dish.price * Double($1.quantity)) }
        newOrder.totalPrice = total
        
        // 5. Save to Core Data
        do {
            try context.save()
            print("✅ Order saved successfully!")
        } catch {
            print("❌ Failed to save order:", error.localizedDescription)
        }
    }
    
    // MARK: - Fetch all orders
    func fetchOrders() -> [Order] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Order> = Order.fetchRequest()

        do {
            let orders = try context.fetch(request)
            return orders
        } catch {
            print("❌ Failed to fetch orders:", error.localizedDescription)
            return []
        }
    }

    // MARK: - Parse orderedDishes JSON into [OrderItem]
    func orderItems(from order: Order) -> [OrderItem] {
        guard let jsonString = order.orderedDishes,
              let jsonData = jsonString.data(using: .utf8) else { return [] }

        do {
            if let array = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                return array.compactMap { dict in
                    guard let dishIDString = dict["dishID"] as? String,
                          let dishUUID = UUID(uuidString: dishIDString),
                          let name = dict["dishName"] as? String,
                          let price = dict["price"] as? Double,
                          let quantity = dict["quantity"] as? Int else { return nil }

                    // Create a temporary Dish object (or fetch actual Dish from Core Data)
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let tempDish = Dish(context: context)
                    tempDish.id = dishUUID
                    tempDish.name = name
                    tempDish.price = price

                    return OrderItem(dish: tempDish, quantity: quantity)
                }
            }
        } catch {
            print("❌ Failed to parse orderedDishes JSON:", error)
        }

        return []
    }

    // MARK: - Update order status
    func updateOrderStatus(orderID: UUID, status: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", orderID as CVarArg)

        do {
            let results = try context.fetch(request)
            if let orderToUpdate = results.first {
                orderToUpdate.status = status
                try context.save()
                print("✅ Order status updated to \(status)")
            } else {
                print("⚠️ Order with id \(orderID) not found")
            }
        } catch {
            print("❌ Failed to update order status:", error.localizedDescription)
        }
    }


    
    
    
    
}

struct OrderItem {
    let dish: Dish   // the menu item
    var quantity: Int // how many of this dish the customer wants
}
