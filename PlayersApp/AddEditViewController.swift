//
//  AddEditViewController.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 31/03/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController();
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var entity : NSEntityDescription! = nil;
    var playersObj : Players! = nil;
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rankTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func pickImageButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self;
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false;
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil);
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
    }
    
}
