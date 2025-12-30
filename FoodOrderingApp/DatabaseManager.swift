//
//  DatabaseManager.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit
import CoreData

class DatabaseManager: NSObject {
    
    func nextDishID() -> Int16 {
        let key = "lastDishID"
        let lastID = UserDefaults.standard.integer(forKey: key)
        let newID = lastID + 1
        UserDefaults.standard.set(newID, forKey: key)
        return Int16(newID)
    }
    
    func addDish(name: String, type: String, price: Double, ingredients: String, image: UIImage){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let dish = Dish(context: context)
               dish.id = nextDishID()
               dish.name = name
               dish.type = type
               dish.ingredients = ingredients
               dish.price = price

               // Store image if available
               dish.image = image.jpegData(compressionQuality: 0.8)

               do {
                   try context.save()
                   print("✅ Dish saved successfully")
               } catch {
                   print("❌ Failed to save dish:", error.localizedDescription)
               }
        
    }
    
    func updateDush(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
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


}
