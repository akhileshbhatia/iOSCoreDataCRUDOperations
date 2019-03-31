//
//  PlayerDetailsViewController.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 03/03/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import UIKit

class PlayerDetailsViewController: UIViewController {
    var playerData : Players!;
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Player Details Info";
        addBackground();
        nameLabel.text = playerData.name;
        detailsLabel.text = playerData.details;
        detailsLabel.sizeToFit();
    }
    
    func addBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds);
        backgroundImage.image = UIImage(named: "bgImage 4");
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill;
        backgroundImage.alpha = 0.5;
        self.view.insertSubview(backgroundImage, at: 0);
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! WebViewController;
//        destination.playerUrl = playerData.url;
        
    }
 

}
