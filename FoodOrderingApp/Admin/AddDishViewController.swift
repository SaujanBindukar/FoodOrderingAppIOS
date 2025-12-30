//
//  AddDishViewController.swift
//  FoodOrderingApp
//
//  Created by Saujan Bindukar on 30/12/2025.
//

import UIKit

class AddDishViewController: UIViewController, UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {
    
    var dishType = "Entry"
    @IBOutlet weak var dishNameController: UITextField!
    @IBOutlet weak var dishTypeController: UISegmentedControl!
    @IBOutlet weak var dishPriceController: UITextField!
    @IBOutlet weak var dishIngredientsController: UITextField!
    
    @IBOutlet weak var dishImageContoller: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    let db = DatabaseManager()
    
    @IBAction func dishTypeSegment(_ sender: Any) {
        let type = dishTypeController.titleForSegment(at: dishTypeController.selectedSegmentIndex)!
        dishType = type
    }
    
    @IBAction func galleryButton(_ sender: Any) {
        openImagePicker(sourceType: .photoLibrary)
    }
    @IBAction func cameraButton(_ sender: Any) {
        openImagePicker(sourceType: .camera)
    }
    @IBAction func addDishButton(_ sender: Any) {
        
        // ✅ Validation
              guard
                  let name = dishNameController.text, !name.isEmpty,
                  let ingredients = dishIngredientsController.text, !ingredients.isEmpty,
                  let priceText = dishPriceController.text,
                  let price = Double(priceText),
                  let image = dishImageContoller.image
              else {
                  showAlert("Missing Information", "Please fill all fields and select an image")
                  return
              }

              // ✅ Save dish
              db.addDish(
                  name: name,
                  type: dishType,
                  price: price,
                  ingredients: ingredients,
                  image: image
              )

              showAlert("Success", "Dish added successfully")
              clearAll()
        
        
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
            dishImageContoller.image = selectedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            dishImageContoller.image = originalImage
        }

        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    func clearAll(){
        dishNameController.text = ""
             dishIngredientsController.text = ""
             dishPriceController.text = ""
             dishImageContoller.image = UIImage(named: "photo.artframe")
             dishTypeController.selectedSegmentIndex = 0
             dishType = "Entry"
        
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


}
