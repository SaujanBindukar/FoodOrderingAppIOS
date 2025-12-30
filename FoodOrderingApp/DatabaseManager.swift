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
    
    func removeDish(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
    }
    
    func getAllDish()-> [Dish]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return []
        }
        let context = appDelegate.persistentContainer.viewContext
        
        return []
    }

}
