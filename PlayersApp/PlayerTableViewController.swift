//
//  PlayerTableViewController.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 16/02/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import UIKit
import CoreData

class PlayerTableViewController: UITableViewController, XMLParserDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    var xmlPlayers: [PlayerInfo] = [];
    var players : [Players] = [];
    var filteredPlayers : [Players] = [];
    var resultSearchController = UISearchController();
    
    let backgroundImage = UIImageView(image: UIImage(named: "bgImage 4"));
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var playersObj : Players! = nil;
    var entity : NSEntityDescription! = nil;
    var frc: NSFetchedResultsController<NSFetchRequestResult>! = nil;
    
    @IBOutlet weak var reorderBtn: UIBarButtonItem!
    
    @IBAction func reorderAction(_ sender: Any) {
        self.tableView.isEditing = !self.tableView.isEditing;
        reorderBtn.title = self.tableView.isEditing ? "Done" : "Reorder";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Top tennis players";
        backgroundImage.frame = self.tableView.frame;
        self.tableView.backgroundView = backgroundImage;
        self.tableView.semanticContentAttribute = .forceRightToLeft;
        let request = getAllPlayersRequest();
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil);
        frc.delegate = self;
        //                                deleteAllRows();
        //                                deleteAllImageFiles();
        if try! context.count(for: request) == 0 {
            print("no data");
            savePlayersFromXMLFile();
        }
        do {
            try frc.performFetch()
            players = frc.fetchedObjects as! [Players];
        }
        catch{
            print("unable to fetch data");
        }
        
        //initialize search bar controller
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil);
            controller.searchResultsUpdater = self;
            controller.obscuresBackgroundDuringPresentation = false;
            controller.searchBar.placeholder = "Search Player by Name";
            tableView.tableHeaderView = controller.searchBar;
            definesPresentationContext = true;
            
            return controller;
        })();
    }
    override func viewDidAppear(_ animated: Bool) {
        players = frc.fetchedObjects as! [Players];
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.isEditing {
            return .none;
        }
        else{
            return .delete;
        }
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObj = players[sourceIndexPath.row];
        players.remove(at: sourceIndexPath.row);
        players.insert(movedObj, at: destinationIndexPath.row);
    }
    func updateSearchResults(for searchController: UISearchController) {
        filteredPlayers.removeAll(keepingCapacity: false);
        //return all players whose name contain the text written in search bar
        filteredPlayers = players.filter{
            $0.name!.lowercased().contains(searchController.searchBar.text!.lowercased());
        }
        self.tableView.reloadData();
    }
    
    func isFiltering() -> Bool {
        return resultSearchController.isActive && !resultSearchController.searchBar.text!.isEmpty;
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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        
        for player in xmlPlayers{
            
            playersObj = Players(context: context);
            
            //save other elements
            playersObj.name = player.name;
            playersObj.country = player.country
            playersObj.ranking = Int64(player.ranking);
            playersObj.url = player.url;
            
            //create file url
            let imageNameWithExtension = String(player.ranking) + ".png";
            let imageUrl = URL(fileURLWithPath: paths.first!).appendingPathComponent(imageNameWithExtension);
            
            //save image to path
            saveImageToPath(image: UIImage(named: player.image)!, path: imageUrl);
        }
        
        do {
            try context.save();
        }
        catch{
            print("unable to save to core data")
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
        players = frc.fetchedObjects as! [Players];
        //reset search bar when view appears
        resultSearchController.searchBar.text = "";
        resultSearchController.isActive = false;
        self.tableView.reloadData();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return filter data count if user is filtering
        if(isFiltering()){
            return filteredPlayers.count;
        }
        else{
            return players.count;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlayerTableViewCell;
        cell.backgroundColor = UIColor(white: 1, alpha: 0.6);
        if (isFiltering()){
            playersObj = filteredPlayers[indexPath.row];
        }
        else{
            playersObj = players[indexPath.row];
        }
        cell.playerName!.text = playersObj.name;
        cell.playerRank!.text = String(playersObj.ranking);
        cell.playerCountry.text = playersObj.country
        cell.playerImage!.image = getImageFromDocumentsDirectory(imageName: String(playersObj.ranking));
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if(isFiltering()){
                playersObj = filteredPlayers[indexPath.row];
            }
            else{
                playersObj = players[indexPath.row];
            }
            context.delete(playersObj);
            do{
                try context.save();
            }
            catch{
                print("Error in deleting the data");
            }
            
            do{
                try frc.performFetch();
                players = frc.fetchedObjects as! [Players];
            }
            catch{
                print("Error in fetching the data after deleting");
            }
            self.tableView.reloadData();
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: 45.0);
        cell.alpha = 0;
        UIView.animate(
            withDuration: 0.5,
            delay: 0.08*Double(indexPath.row),
            options: .curveEaseInOut,
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
                cell.alpha = 1
        },
            completion: nil
        );
    }
    
    func getImageFromDocumentsDirectory(imageName : String) -> UIImage {
        let imageNameWithExtension = imageName + ".png";
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let imageUrl = URL(fileURLWithPath: paths.first!).appendingPathComponent(imageNameWithExtension);
        return UIImage(contentsOfFile: imageUrl.path)!;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue"{
            let destination = segue.destination as! AddEditViewController
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell);
            if (isFiltering()){
                destination.playersObj = filteredPlayers[indexPath!.row];
            }
            else{
                destination.playersObj = players[indexPath!.row];
            }
        }
    }
    
}
