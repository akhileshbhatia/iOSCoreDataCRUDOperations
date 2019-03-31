//
//  XMLPlayersParser.swift
//  PlayersApp
//
//  Created by Akhilesh Bhatia on 07/03/2019.
//  Copyright © 2019 Akhilesh Bhatia. All rights reserved.
//

import Foundation
class XMlPlayersParser : NSObject, XMLParserDelegate {
    var players = [PlayerInfo] ();
    var elementName: String = String();
    var name = String();
    var country = String();
    var ranking = Int();
    var details = String();
    var image = String();
    var url = String();
    
    func parsePlayerData(){
        //parse the data
        if let path = Bundle.main.url(forResource: "players", withExtension: "xml"){
            if let parser = XMLParser(contentsOf: path){
                parser.delegate = self;
                parser.parse();
            }
        }

    }
    
    //begin parsing when player tag is encountered
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "player" {
            name = String();
            country = String();
            ranking = Int();
            details = String();
            image = String();
            url = String();
        }
        self.elementName = elementName;
    }
    //add to array when parsing of one player is complete
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "player" {
            let playerInfo = PlayerInfo(name: name, country: country, ranking: ranking, details: details, image: image, url: url);
            players.append(playerInfo);
        }
    }
    //parsing
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        
        if(!data.isEmpty){
            switch self.elementName {
            case "name":
                name += data;
                break;
            case "country":
                country += data;
                break;
            case "world-ranking":
                ranking += Int(data)!;
                break;
            case "details":
                details += data;
                break;
            case "image":
                image += data;
                break;
            case "url":
                url += data;
                break;
            default:
                break;
            }
        }
    }

}
