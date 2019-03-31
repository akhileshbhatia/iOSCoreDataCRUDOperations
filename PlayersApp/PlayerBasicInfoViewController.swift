//
//  PlayerBasicInfoViewController.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 03/03/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import UIKit

class PlayerBasicInfoViewController: UIViewController {
    var playerData : Players!;
    
    @IBOutlet weak var playerImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Player Basic Info"
        addBackground();
//        playerImageView.image = UIImage(named: playerData.image);
        nameLabel.text = playerData.name;
        countryLabel.text = playerData.country;
        rankLabel.text = String(playerData.ranking);
        
    }
    
    func addBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds);
        backgroundImage.image = UIImage(named: "bgImage 4");
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill;
        backgroundImage.alpha = 0.5;
        self.view.insertSubview(backgroundImage, at: 0);
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PlayerDetailsViewController;
        destination.playerData = self.playerData;
        
    }
 

}
