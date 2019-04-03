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
    let backgroundImage = UIImageView(image: UIImage(named: "bgImage 4"));
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var entity : NSEntityDescription! = nil;
    var playersObj : Players! = nil;
    var IsNewPlayer = false;
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rankTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
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
        //if editing existing player, then delete the player data first
        if !self.IsNewPlayer{
            deleteExistingPlayer();
        }
        
        if isUserInputValid() {
            saveToCoreData();
            saveImageToPath();
            navigationController?.popViewController(animated: true);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackground();
        if playersObj == nil {
            imageView.image = UIImage(named: "profilePic.jpg");
            self.IsNewPlayer = true;
        }
        else{
            nameTextField.text = playersObj.name;
            rankTextField.text = String(playersObj.ranking);
            countryTextField.text = playersObj.country;
            imageView.image = getImageFromDocumentsDirectory(imageName: rankTextField.text!);
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil);
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
    }
    
    func addBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds);
        backgroundImage.image = UIImage(named: "bgImage 4");
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill;
        backgroundImage.alpha = 0.5;
        self.view.insertSubview(backgroundImage, at: 0);
    }
    
    func isUserInputValid() -> Bool{
        let alert = UIAlertController(title: "Error", message: "default message", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
        if (nameTextField.text?.isEmpty)! {
            alert.message = "Name field is mandatory";
            self.present(alert,animated: true);
        }
        else if (rankTextField.text?.isEmpty)!{
            alert.message = "Ranking field is mandatory";
            self.present(alert,animated: true);
        }
        else if (Int(rankTextField.text!) == nil){
            alert.message = "Please enter a proper number in the rank field";
            self.present(alert,animated: true);
        }
        else if (doesRankAlreadyExist(rank: Int(rankTextField.text!)!)){
            alert.message = "A player with the same rank already exists. Please add a player with new ranking";
            self.present(alert,animated: true);
        }
        else if(countryTextField.text?.isEmpty)!{
            alert.message = "Country field is mandatory";
            self.present(alert,animated: true);
        }
        else if(imageView.image == UIImage(named: "profilePic.jpg")){
            alert.message = "Please select an image other than default image";
            self.present(alert,animated: true);
        }
        else{
            return true;
        }
        return false;
    }
    
    func doesRankAlreadyExist(rank : Int) -> Bool{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players");
        request.predicate = NSPredicate(format: "ranking = %d", rank);
        var count = 0;
        do{
            count = try context.count(for: request);
        }
        catch{
            print("Error in checking if rank already exists");
        }
        return count > 0;
    }
    
    func saveToCoreData(){
        playersObj = Players(context: context);
        
        playersObj.name = nameTextField.text;
        playersObj.ranking = Int64(rankTextField.text!)!;
        playersObj.country = countryTextField.text;
        
        do{
            try context.save();
        }
        catch{
            print("Error in saving new player");
        }
    }
    
    func saveImageToPath(){
        let imageNameWithExtension = rankTextField.text! + ".png";
        let imageUrl = URL(fileURLWithPath: paths.first!).appendingPathComponent(imageNameWithExtension);
        //save the image from image view
        do{
            if let pngImageData = UIImagePNGRepresentation(imageView.image!){
                try pngImageData.write(to: imageUrl)
                print("saved image successfully");
            }
        }catch{
            print("Unable to save image in documents directory")
        }
    }
    
    func getImageFromDocumentsDirectory(imageName : String) -> UIImage {
        let imageNameWithExtension = imageName + ".png";
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let imageUrl = URL(fileURLWithPath: paths.first!).appendingPathComponent(imageNameWithExtension);
        return UIImage(contentsOfFile: imageUrl.path)!;
    }
    
    func deleteExistingPlayer(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players");
        request.predicate = NSPredicate(format: "ranking = %d", Int(playersObj.ranking));
        let result = try? context.fetch(request);
        let resultData = result as! [Players]
        
        for obj in resultData{
            context.delete(obj);
        }
        do{
            try context.save();
        }
        catch{
            print("Error in saving after deleting existing player");
        }
    }
    
}
