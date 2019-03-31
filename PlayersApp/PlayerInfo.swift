//
//  PlayerInfo.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 16/02/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import Foundation
class PlayerInfo{
    //properties
    var name: String;
    var country: String;
    var ranking: Int;
    var details : String;
    var image : String;
    var url : String;
    
    //initializors
    init(name: String, country: String, ranking: Int, details: String, image: String, url: String){
        self.name = name;
        self.country = country;
        self.ranking = ranking;
        self.details = details;
        self.image = image;
        self.url = url;
    }
    
    init() {
        self.name = "";
        self.country = "";
        self.ranking = 0;
        self.details = "";
        self.image = "";
        self.url = "";
    }
}
