//
//  AdminDishViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit
import Foundation

extension Notification.Name {
    static let dishAdded = Notification.Name("dishAdded")
}

class AdminDishViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    let db = DatabaseManager()
    
    // Dishes grouped by type
    var entryDishes: [Dish] = []
    var mainDishes: [Dish] = []
    var drinkDishes: [Dish] = []
    
    // For multi-selection
    var selectedDishes: [Dish] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = 100
        
        fetchData()
        
        deleteButton.isHidden = true
        cancelButton.isHidden = true
        
        // Add long press gesture for multi-selection
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDishes), name: .dishAdded, object: nil)
    }
    
    @objc func refreshDishes() {
        fetchData()  // reloads the table view with latest data
    }

    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        setEditing(false, animated: true)
    }
    @IBAction func deleteButtonClicked(_ sender: Any) {
        guard !selectedDishes.isEmpty else { return }
        
        let alert = UIAlertController(title: "Delete Dishes", message: "Are you sure you want to delete selected dishes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            for dish in self.selectedDishes {
                self.db.deleteDish(dish: dish)
            }
            self.selectedDishes.removeAll()
            self.fetchData()
            self.setEditing(false, animated: true)
        }))
        present(alert, animated: true)
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
        
        let dish = dishFor(indexPath: indexPath)
        
        cell.nameLabel.text = dish.name
        cell.typeLabel.text = dish.ingredients
        cell.priceLabel.text = "$\(dish.price)"
        
        if let imageData = dish.image {
            cell.dishImageView.image = UIImage(data: imageData)
        } else {
            cell.dishImageView.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
    
    // MARK: - Handle Long Press
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                setEditing(true, animated: true)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                
                let dish = dishFor(indexPath: indexPath)
                selectedDishes.append(dish)
            }
        }
    }
    
    // MARK: - Selection / Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dish = dishFor(indexPath: indexPath)
        
        if tableView.isEditing {
            selectedDishes.append(dish)
        } else {
            navigateToEditDish(dish)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let dish = dishFor(indexPath: indexPath)
            if let index = selectedDishes.firstIndex(where: { $0.id == dish.id }) {
                selectedDishes.remove(at: index)
            }
        }
    }
    
    // MARK: - Editing Mode & Delete
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        
        if editing {
            deleteButton.isHidden = false
            cancelButton.isHidden = false
        } else {
            deleteButton.isHidden = true
            cancelButton.isHidden = true
            selectedDishes.removeAll()
            tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: false) }
        }
    }
    
    
    // MARK: - Navigation to Edit Page
    func navigateToEditDish(_ dish: Dish) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditDishViewController") as? EditDishViewController {
            editVC.dish = dish
            editVC.delegate = self
            navigationController?.pushViewController(editVC, animated: true)
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

}

// MARK: - Protocol to refresh after edit
protocol DishUpdateDelegate: AnyObject {
    func didUpdateDish()
}

extension AdminDishViewController: DishUpdateDelegate {
    func didUpdateDish() {
        fetchData()
    }
}

