//
//  AIMOnAirDocumentParser.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 28/6/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import Foundation

protocol  OnAirDocumentParser{
    
    init?(withFile file:String)
    init?(withString rawString:String)
    init?(withData data:Data)
    
    var delegate:OnAirDocumentParserDelegate? {set get}
    func parse()
    
}

protocol OnAirDocumentParserDelegate {
    
    func parser(parser:OnAirDocumentParser, didFinishWithParsingResult result:OnAirDocument?)
    func parser(parser:OnAirDocumentParser, didFailWithError error:Error?)
}
