//
//  OnAirDocument.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 28/6/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class onAirDocumentItem {
    
    var time:Date?
    var duration:Date?
    var customFields:Dictionary<String,String>?
    
    init(with dictionary:Dictionary<String,Any>) {
        
        if let timeValue = dictionary["time"] as? String {
            time = onAirDocumentItem.date(from: timeValue, format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ")
        }
        
        if let durationValue = dictionary["duration"] as? String {
            duration = onAirDocumentItem.date(from: durationValue, format: "HH:mm:ss")
        }
        
        if let rawCustomFields = dictionary["customFields"] as? Array<Dictionary<String,String>>{
            
            var tempName:String?
            var tempValue:String?
            customFields = [String:String]()
            
            for customField in rawCustomFields {
                
                tempName = customField["name"]
                tempValue = customField["value"]
                
                if tempName != nil && tempValue != nil && tempName!.characters.count > 0 && tempValue!.characters.count > 0 {
                    
                    customFields![tempName!] = tempValue!
                }
                
                tempName = nil
                tempValue = nil
                
            }
            
        }
        
    }
    
    func time(asStringWith format:String!) -> String? {
        return time != nil ? onAirDocumentItem.date(asStringFrom: time!, format: format): nil
    }
    
    func duration(asStringWith format:String!) -> String? {
        return duration != nil ? onAirDocumentItem.date(asStringFrom: duration!, format: format): nil
    }
    
    private static func date(from string:String!, format:String!) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: string)
    }
    
    private static func date(asStringFrom date:Date!, format:String!) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
}

class onAirPlayoutItem:onAirDocumentItem,Equatable {
    
    enum PlayoutItemStatus: String {
        case unknown, playing, history
    }
    
    enum PlayoutItemType:String {
        case unknown, song
    }
    
    var title:String?
    var album:String?
    var type:PlayoutItemType
    var status:PlayoutItemStatus
    var artist:String?
    var imageURL:String?
    
    override init(with dictionary: Dictionary<String, Any>) {
        
        type = (dictionary["type"] as? String).map{ PlayoutItemType(rawValue: $0)! } ?? .unknown
        status = (dictionary["status"] as? String).map { PlayoutItemStatus(rawValue: $0)! } ?? .unknown
        title = dictionary["title"] as? String
        artist = dictionary["artist"] as? String
        imageURL = dictionary["imageUrl"] as? String
        album = dictionary["album"] as? String
        super.init(with: dictionary)
    }
    
    static func ==(lhs:onAirPlayoutItem, rhs: onAirPlayoutItem) -> Bool{ return lhs === rhs }
}

class onAirEPGItem:onAirDocumentItem,Equatable {
    
    var epgID:String?
    var name:String?
    var epgDescription:String?
    var presenter:String?
    
    override init(with dictionary: Dictionary<String, Any>) {
        super.init(with: dictionary)
        
        epgID = dictionary["id"] as? String
        name = dictionary["name"] as? String
        epgDescription = dictionary["description"] as? String
        presenter = dictionary["presenter"] as? String
    }
    
    static func ==(lhs: onAirEPGItem, rhs: onAirEPGItem) -> Bool { return lhs === rhs }
    
}

class OnAirDocument {

    private var epgs:Array<onAirEPGItem>
    private var playouts:Array<onAirPlayoutItem>
    
    public var epgItems: [onAirEPGItem]{
        
        get{
            let tempEPGS = epgs
            return tempEPGS
            
        }
    }
    
    init(epgItems:Array<onAirEPGItem>!, playoutItems:Array<onAirPlayoutItem>!) {
        epgs = epgItems
        playouts = playoutItems
    }
    
    func addEPG(epg:onAirEPGItem) {
        
        epgs.append(epg)
    }
    
    func removeEPG(epg:onAirEPGItem) {
        
        if let theIndex = epgs.index(of: epg) {
            epgs.remove(at: theIndex)
        }
        
    }
    
    public var playoutItems: [onAirPlayoutItem]{
        
        get{
            let tempPlayouts = playouts
            return tempPlayouts
            
        }
    }
    
    func addPlayout(playout:onAirPlayoutItem) {
        
        playouts.append(playout)
    }
    
    func removePlayout(playout:onAirPlayoutItem) {
        
        if let theIndex = playouts.index(of: playout) {
            playouts.remove(at: theIndex)
        }
        
    }
    
}
