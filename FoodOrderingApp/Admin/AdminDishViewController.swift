//
//  AdminDishViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit

class AdminDishViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let db = DatabaseManager()
    
    // Dishes grouped by type (Entry, Main, Drink)
    var entryDishes: [Dish] = []
    var mainDishes: [Dish] = []
    var drinkDishes: [Dish] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Row height
        tableView.rowHeight = 100
        
        fetchData()
    }
    
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
            withIdentifier: "dishViewCell",
            for: indexPath
        ) as! DishViewCell
        
        let dish: Dish
        
        switch indexPath.section {
        case 0: dish = entryDishes[indexPath.row]
        case 1: dish = mainDishes[indexPath.row]
        case 2: dish = drinkDishes[indexPath.row]
        default:
            fatalError("Invalid section")
        }
        
        cell.nameLabel.text = dish.name
        cell.typeLabel.text = dish.ingredients
        cell.priceLabel.text = "$\(dish.price)"
        
        if let imageData = dish.image {
            cell.dishImageView.image = UIImage(data: imageData)
        } else {
            cell.dishImageView.image = UIImage(systemName: "photo") // placeholder
        }
        
        return cell
    }
    
    // MARK: - Row Selection (for Edit / Delete later)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dish: Dish
        switch indexPath.section {
        case 0: dish = entryDishes[indexPath.row]
        case 1: dish = mainDishes[indexPath.row]
        case 2: dish = drinkDishes[indexPath.row]
        default: return
        }
        
        // Navigate to EditDishViewController (create this screen separately)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let editVC = storyboard.instantiateViewController(
//            withIdentifier: "EditDishViewController") as? EditDishViewController {
//            
//            editVC.dish = dish
//            editVC.delegate = self // Create protocol to refresh after edit
//            self.navigationController?.pushViewController(editVC, animated: true)
//        }
    }

}

// MARK: - Optional: Protocol for refreshing after edit
protocol DishUpdateDelegate {
    func didUpdateDish()
}

extension AdminDishViewController: DishUpdateDelegate {
    func didUpdateDish() {
        fetchData()
    }
}
