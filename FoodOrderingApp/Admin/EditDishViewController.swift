//
//  EditDishViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 23/01/2026.
//

import UIKit

class EditDishViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var dish: Dish!  // The dish being edited
    weak var delegate: DishUpdateDelegate?
    
    let db = DatabaseManager()
    var dishType: String = "Entry"

    @IBOutlet weak var dishNameController: UITextField!
    @IBOutlet weak var dishTypeController: UISegmentedControl!
    
    @IBOutlet weak var dishIngredientsController: UITextField!
    @IBOutlet weak var dishPriceController: UITextField!
    
    @IBOutlet weak var dishImageController: UIImageView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            populateFields()
        }

    func populateFields() {
            dishNameController.text = dish.name
            dishIngredientsController.text = dish.ingredients
            dishPriceController.text = "\(dish.price)"
            dishType = dish.type!
            switch dish.type {
            case "Entry": dishTypeController.selectedSegmentIndex = 0
            case "Main": dishTypeController.selectedSegmentIndex = 1
            case "Drinks": dishTypeController.selectedSegmentIndex = 2
            default: dishTypeController.selectedSegmentIndex = 0
            }
            if let data = dish.image {
                dishImageController.image = UIImage(data: data)
            } else {
                dishImageController.image = UIImage(named: "photo.artframe")
            }
        }
    
    @IBAction func dishTypeSegment(_ sender: Any) {
        if let type = dishTypeController.titleForSegment(at: dishTypeController.selectedSegmentIndex) {
                    dishType = type
                }
        
    }
    @IBAction func galleryButton(_ sender: Any) {
        openImagePicker(sourceType: .photoLibrary)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        openImagePicker(sourceType: .camera)
    }
    @IBAction func updateDishButton(_ sender: Any) {
        guard
                  let name = dishNameController.text, !name.isEmpty,
                  let ingredients = dishIngredientsController.text, !ingredients.isEmpty,
                  let priceText = dishPriceController.text, let price = Double(priceText),
                  let image = dishImageController.image,
                  let dishID = dish.id
              else {
                  showAlert("Missing Information", "Please fill all fields and select an image")
                  return
              }

              // Update dish in DB
              db.updateDish(
                  id: dishID,
                  name: name,
                  type: dishType,
                  price: price,
                  ingredients: ingredients,
                  image: image
              )

              delegate?.didUpdateDish()  // refresh AdminDishViewController
              showAlert("Success", "Dish updated successfully") {
                  self.navigationController?.popViewController(animated: true)
              }
        
          }
    @IBAction func deleteDishButton(_ sender: Any) {
        // Confirm deletion
           let alert = UIAlertController(title: "Delete Dish",
                                         message: "Are you sure you want to delete this dish?",
                                         preferredStyle: .alert)
           
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           
           alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
               // Delete from Core Data
               let db = DatabaseManager()
               db.deleteDish(dish: self.dish)
               
               // Notify delegate to refresh Admin list
               self.delegate?.didUpdateDish()
               
               // Go back to AdminDishViewController
               self.navigationController?.popViewController(animated: true)
           }))
           
           present(alert, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
           if UIImagePickerController.isSourceTypeAvailable(sourceType) {
               let picker = UIImagePickerController()
               picker.sourceType = sourceType
               picker.delegate = self
               picker.allowsEditing = true
               present(picker, animated: true)
           }
       }

       func imagePickerController(_ picker: UIImagePickerController,
                                  didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[.editedImage] as? UIImage {
               dishImageController.image = selectedImage
           } else if let originalImage = info[.originalImage] as? UIImage {
               dishImageController.image = originalImage
           }
           dismiss(animated: true)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true)
       }

       func showAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
           present(alert, animated: true)
       }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
