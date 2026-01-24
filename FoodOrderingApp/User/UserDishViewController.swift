//
//  UserDishViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 23/01/2026.
//

import UIKit

class UserDishViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = DatabaseManager()
    
    // Dishes grouped by type
    var entryDishes: [Dish] = []
    var mainDishes: [Dish] = []
    var drinkDishes: [Dish] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
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
            withIdentifier: "userDishCell",
            for: indexPath
        ) as! UserDishViewCell
        
        let dish = dishFor(indexPath: indexPath)
        
        cell.nameLabel.text = dish.name
        cell.typeLabel.text = dish.type
        cell.priceLabel.text = "$\(dish.price)"
        cell.ingredientLabel.text = dish.ingredients
        
        if let imageData = dish.image {
            cell.dishImageView.image = UIImage(data: imageData)
        } else {
            cell.dishImageView.image = UIImage(systemName: "photo")
        }
        
        return cell
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
    

}
