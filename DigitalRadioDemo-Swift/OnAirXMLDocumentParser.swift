//
//  OnAirXMLDocumentParser.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 28/6/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit


class OnAirXMLDocumentParser: NSObject,OnAirDocumentParser,XMLParserDelegate {

    private let xmlParser:XMLParser
    private var parsedDocument:OnAirDocument?
    private let dispatchQueue = DispatchQueue(label: "com.thisisaim.xmlParser", attributes:.concurrent)
    
    private var epgItems:Array<onAirEPGItem>?
    private var playoutitems:Array<onAirPlayoutItem>?
    private var customFields:Array<Dictionary<String,String>>?
    private var item:Dictionary<String,Any>?
    
    
    required init?(withString rawString:String) {
        if rawString.characters.count > 0 {
            if let stringData = rawString.data(using: String.Encoding.utf8) {
                xmlParser = XMLParser(data: stringData)
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    required init?(withFile file:String) {
        if file.characters.count > 0 {
            if let tempXMLParser = XMLParser(contentsOf:URL(fileURLWithPath: file)) {
                xmlParser = tempXMLParser
            }else{
                return nil
            }
        }else{
            return nil
        }
        
    }
    
    required init?(withData data:Data) {
        if data.count > 0 {
            xmlParser = XMLParser(data: data)
        }else{
            return nil
        }
    }
    
    var delegate: OnAirDocumentParserDelegate?
    
    func parse() {
        
        parsedDocument = nil
        xmlParser.delegate = self
        
        dispatchQueue.async {
            
            let parsed = self.xmlParser.parse()
            
            if parsed {
                    
                DispatchQueue.main.async {
                    self.delegate?.parser(parser: self, didFinishWithParsingResult: self.parsedDocument)
                }
            }else{
                
                DispatchQueue.main.async {
                    self.delegate?.parser(parser: self, didFailWithError: self.xmlParser.parserError)
                }
            }
        }
    }
    
    private func clearAll(){
        
        epgItems?.removeAll()
        epgItems = nil
        
        playoutitems?.removeAll()
        playoutitems = nil
        
        item?.removeAll()
        item = nil
        
        customFields?.removeAll()
        customFields = nil
    }
    
    // MARK: XMLParserDelegate methods
    internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        switch elementName {
        case "onAir":
            clearAll()
        case "epgData":
            epgItems = [onAirEPGItem]()
        case "playoutData":
            playoutitems = [onAirPlayoutItem]()
        case "customFields":
            customFields = [Dictionary<String,String>]()
        case "customField":
            customFields?.append(attributeDict)
        case "epgItem","playoutItem":
            item = attributeDict
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName {
        case "onAir":
            parsedDocument = OnAirDocument(epgItems: epgItems ?? [onAirEPGItem](), playoutItems: playoutitems ?? [onAirPlayoutItem]())
        case "epgData":
            break
        case "playoutData":
            break
        case "customFields":
            item?["customFields"] = customFields
        case "customField":
            break
        case "epgItem":
            epgItems?.append(onAirEPGItem(with: item!))
        case "playoutItem":
            playoutitems?.append(onAirPlayoutItem(with: item!))
            
        default:
            break
        }
        
    }
    
    deinit {
        clearAll()
        parsedDocument = nil
    }
}

