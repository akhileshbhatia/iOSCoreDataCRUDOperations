//
//  PlayerTableViewController.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 16/02/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import UIKit
import CoreData

class PlayerTableViewController: UITableViewController, XMLParserDelegate, NSFetchedResultsControllerDelegate {
    
    var xmlPlayers: [PlayerInfo] = [];
    var players : [Players] = [];
    
    let backgroundImage = UIImageView(image: UIImage(named: "bgImage 4"));
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var playersObj : Players! = nil;
    var entity : NSEntityDescription! = nil;
    var frc: NSFetchedResultsController<NSFetchRequestResult>! = nil;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Top tennis players";
        backgroundImage.frame = self.tableView.frame;
        self.tableView.backgroundView = backgroundImage;
        
        let request = getAllPlayersRequest();
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil);
        frc.delegate = self;
//                deleteAllRows();
//                deleteAllImageFiles();
        if try! context.count(for: request) == 0 {
            print("no data");
            savePlayersFromXMLFile();
        }
        do {
            try frc.performFetch()
        }
        catch{
            print("unable to fetch data");
        }
    }
    
    func getAllPlayersRequest() -> NSFetchRequest<NSFetchRequestResult>{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players");
        let sorter = NSSortDescriptor(key: "ranking", ascending: true);
        request.sortDescriptors = [sorter];
        return request;
    }
    
    func savePlayersFromXMLFile(){
        //initialize parser, parse and get data after parsing
        let xmlParser = XMlPlayersParser();
        xmlParser.parsePlayerData();
        xmlPlayers = xmlParser.players;
        
        //initialize document directory
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        
        for player in xmlPlayers{
            
            playersObj = Players(context: context);
            
            //save other elements
            playersObj.name = player.name;
            playersObj.country = player.country
            playersObj.ranking = Int64(player.ranking);
            playersObj.details = player.details;
            playersObj.url = player.url;
            
            //create file url and save to core data
            let imageName = String(player.ranking) + ".png";
            let imageUrl = documentsUrl.appendingPathComponent(imageName);
            playersObj.imagePath = imageUrl.absoluteString;
            
            //save image to path
            saveImageToPath(image: UIImage(named: player.image)!, path: imageUrl);
            
            do {
                try context.save();
            }
            catch{
                print("unable to save to core data")
            }
            
            print("Added player \(player.ranking)");
        }
        
    }
    
    func saveImageToPath(image : UIImage, path: URL){
        do{
            if let pngImageData = UIImagePNGRepresentation(image){
                try pngImageData.write(to: path)
            }
        }catch{
            print("Unable to save image in documents directory")
        }
    }
    
    func deleteAllRows(){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Players");
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch);
        do{
            try context.execute(deleteRequest);
            print("data deleted successfully");
        }
        catch{
            print("Error in deleting from core data");
        }
    }
    
    func deleteAllImageFiles(){
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        do{
            let fileUrls = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles,.skipsSubdirectoryDescendants]);
            var index = 1;
            for fileUrl in fileUrls{
                if fileUrl.pathExtension == "png"{
                    try FileManager.default.removeItem(at: fileUrl);
                    print("Deleted file \(index)");
                    index = index + 1;
                }
            }
        }
        catch{
            print("Error in deleting from documents directory");
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections![section].numberOfObjects;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlayerTableViewCell;
        cell.backgroundColor = UIColor(white: 1, alpha: 0.6);
        playersObj = frc.object(at: indexPath) as! Players;
        cell.playerName!.text = playersObj.name;
        cell.playerRank!.text = String(playersObj.ranking);
        cell.playerImage!.image = getImageFromDocumentsDirectory(imageName: String(playersObj.ranking));
        return cell
    }
    
    func getImageFromDocumentsDirectory(imageName : String) -> UIImage {
        let imageNameWithExtension = imageName + ".png";
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let imageUrl = URL(fileURLWithPath: paths.first!).appendingPathComponent(imageNameWithExtension);
        print("from function - \(imageUrl.path)")
        return UIImage(contentsOfFile: imageUrl.path)!;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! PlayerBasicInfoViewController
        let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell);
        playersObj = frc.object(at: indexPath!) as! Players;
        destination.playerData = playersObj;
        
        
    }
    
}
