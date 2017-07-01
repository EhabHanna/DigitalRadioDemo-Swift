//
//  DigitalRadioDemo_SwiftTests.swift
//  DigitalRadioDemo-SwiftTests
//
//  Created by Ehab Hanna on 28/6/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import XCTest
@testable import DigitalRadioDemo_Swift

class DigitalRadioDemo_SwiftTests: XCTestCase, OnAirDocumentParserDelegate {
    
    var testExpectation:XCTestExpectation?
    var parsedDocument:OnAirDocument?
    var parsingError:Error?
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlayoutItem (){
        
        let testDict = ["time":"2017-06-23T10:04:20+10:00",
                        "title":"The Way You Used To Do",
                        "duration":"00:03:24",
                        "artist":"Queens Of The Stone Age",
                        "status":"history",
                        "type":"song" ,
                        "imageUrl":"http://www.abc.net.au/triplej/albums/56045/covers/190.jpg"]
        
        let item = onAirPlayoutItem(with: testDict)
        
        XCTAssert(item.time != nil,"your time should have a value")
        XCTAssert(item.duration != nil, "your duration should have a value")
        XCTAssert(item.title == testDict["title"], "titles don't match")
        XCTAssert(item.artist == testDict["artist"], "artists don't match")
        XCTAssert(item.status == onAirPlayoutItem.PlayoutItemStatus.history, "your status should be history")
        XCTAssert(item.type == onAirPlayoutItem.PlayoutItemType.song, "your type should be song")
        XCTAssert(item.imageURL == testDict["imageUrl"],"your urls don't match")
        
    }
    
    func testEPGtItem (){
        
        let testDict = ["time":"2017-06-23T10:04:20+10:00",
                        "id":"160",
                        "duration":"00:03:24",
                        "name":"Mornings",
                        "description":"Zan Rowe brings you new music and exclusives to your morning. Listen up for album interviews and tips on your new favourite band.",
                        "presenter":"Zan Rowe" ,
                        ]
        
        let item = onAirEPGItem(with: testDict)
        
        XCTAssert(item.time != nil,"your time should have a value")
        XCTAssert(item.duration != nil, "your duration should have a value")
        XCTAssert(item.epgID == testDict["id"], "ids don't match")
        XCTAssert(item.name == testDict["name"], "names don't match")
        XCTAssert(item.presenter == testDict["presenter"], "presenters don't match")
        XCTAssert(item.epgDescription == testDict["description"], "presenters don't match")
        
    }
    
    func testCustomFields (){
        
        let testDict = ["customFields":[
            ["name":"image320","value":"http://www.abc.net.au/triplej/programs/img/2017/mornings_zan/background.jpg"],["name":"displayTime","value":"Mon-Fri 9am-12pm"]
            ]
        ]
        
        let item = onAirEPGItem (with: testDict)
        
        XCTAssert((item.customFields?.count == 2), "should have 2 custom fields");
        XCTAssert(item.customFields? ["displayTime"] == testDict["customFields"]?[1]["value"],"stored custom value does not match provided value");
    }
    
    func testXMLParserWithEmptyString () {
        
        let xmlString = ""
        var parser = OnAirXMLDocumentParser(withString: xmlString)
        XCTAssertNil(parser,"parser should not have a value when initiated with empty string")
        
        parser = OnAirXMLDocumentParser(withFile: xmlString)
        XCTAssertNil(parser,"parser should not have a value when initiated with empty filePath")
        
    }
    
    func testXMLParserWithEmptyXML (){
        
        let xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        let parser = OnAirXMLDocumentParser(withString: xmlString)
        XCTAssertNotNil(parser, "parser should have a value because it is a valid XML document")
        
        parser?.delegate = self
        
        testExpectation = expectation(description: "parser should be able to parse non null input")
        parser?.parse()
        
        waitForExpectations(timeout: 10.0) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        XCTAssertNil(parsedDocument, "should not have a document with empty xml");
        XCTAssertNotNil(self.parsingError, "should have an error");
        
    }
    
    func testXMLParserWithInvalidXML (){
        
        let xmlString = "<arbitrary>"
        let parser = OnAirXMLDocumentParser(withString: xmlString)
        XCTAssertNotNil(parser, "parser should have a value because it is a non null object")
        
        parser?.delegate = self
        
        testExpectation = expectation(description: "parser should be able to parse non null input")
        parser?.parse()
        
        waitForExpectations(timeout: 10.0) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        XCTAssertNil(parsedDocument, "should not have a document with invalid xml")
        XCTAssertNotNil(self.parsingError, "should have an error")
        
    }
    
    func testXMLParserWithFile (){
        
        if let xmlString = Bundle.main.path(forResource: "onair", ofType: "xml"){
            
            let parser = OnAirXMLDocumentParser(withFile: xmlString)
            XCTAssertNotNil(parser, "parser should have a value because it is a non null object")
            
            parser?.delegate = self
            
            testExpectation = expectation(description: "parser should be able to parse non null input")
            parser?.parse()
            
            waitForExpectations(timeout: 10.0) { (error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            XCTAssertNotNil(self.parsedDocument,"parsed document should have a value")
            XCTAssert(self.parsedDocument!.epgItems.count == 1,"the document should have 1 epg item")
            XCTAssert(self.parsedDocument!.playoutItems.count == 20,"the document should have 20 playout items")

        }else{
            XCTFail("the test file onair.xml was not found in the main bundle, check that is added to the test target")
        }
        
        
    }
    
    func testXMLParserWithEPGString (){
        
        let id = "160"
        let name = "Mornings"
        let description = "Zan Rowe brings you new music and exclusives to your morning. Listen up for album interviews and tips on your new favourite band."
        
        let customField1Name = "image320"
        let customField1Value = "http://www.abc.net.au/triplej/programs/img/2017/mornings_zan/background.jpg"
        
        let customField2Name = "displayTime"
        let customField2Value = "Mon-Fri 9am-12pm"
        
        let customField3Name = "image640"
        let customField3Value = "http://www.abc.net.au/triplej/programs/img/2017/mornings_zan/background640.jpg"
        
        let customField4Name = "image70"
        let customField4Value = "http://www.abc.net.au/triplej/programs/img/2017/mornings_zan/70.jpg"
        
        let customField5Name = "image50"
        let customField5Value = "http://www.abc.net.au/triplej/programs/img/2017/mornings_zan/50.jpg"
        
        let xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <onAir> <epgData> <epgItem id=\"\(id)\" name=\"\(name)\" description=\"\(description)\" time=\"2017-06-23T09:00:00+10:00\" duration=\"03:00:00\" presenter=\"\" > <customFields> <customField name=\"\(customField1Name)\" value=\"\(customField1Value)\" /> <customField name=\"\(customField2Name)\" value=\"\(customField2Value)\" /> <customField name=\"\(customField3Name)\" value=\"\(customField3Value)\" /> <customField name=\"\(customField4Name)\" value=\"\(customField4Value)\" /> <customField name=\"\(customField5Name)\" value=\"\(customField5Value)\" /> </customFields> </epgItem> </epgData> </onAir>"
        let parser = OnAirXMLDocumentParser(withString: xmlString)
        XCTAssertNotNil(parser, "parser should have a value because it is a valid XML document")
        
        parser?.delegate = self
        
        testExpectation = expectation(description: "parser should be able to parse non null input")
        parser?.parse()
        
        waitForExpectations(timeout: 10.0) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        XCTAssertNotNil(self.parsedDocument,"parsed document should have a value")
        XCTAssert(self.parsedDocument!.epgItems.count == 1,"the document should have 1 epg item")
        
        let epgItem = parsedDocument!.epgItems.last!
        
        XCTAssertEqual(id, epgItem.epgID, "epg ids are not matching")
        XCTAssertEqual(name, epgItem.name, "epg names are not matching")
        XCTAssertEqual(description, epgItem.epgDescription, "epg descriptions are not matching")
        XCTAssert(epgItem.customFields?.count == 5, "epg should have 5 custom fields")
        XCTAssertEqual(epgItem.customFields?[customField1Name], customField1Value, "custom field 1 not matched")
        XCTAssertEqual(epgItem.customFields?[customField2Name], customField2Value, "custom field 2 not matched")
        XCTAssertEqual(epgItem.customFields?[customField3Name], customField3Value, "custom field 3 not matched")
        XCTAssertEqual(epgItem.customFields?[customField4Name], customField4Value, "custom field 4 not matched")
        XCTAssertEqual(epgItem.customFields?[customField5Name], customField5Value, "custom field 5 not matched")
    }
    
    func testXMLParserWithPlayoutString (){
        
        let title = "The Way You Used To Do"
        let artist = "Queens Of The Stone Age"
        let album = "The Way You Used To Do {Single}"
        let status = "playing"
        let type = "song"
        let imageURL = "http://www.abc.net.au/triplej/albums/56045/covers/190.jpg"
        
        let xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <onAir><playoutData> <playoutItem time=\"2017-06-23T10:04:20+10:00\" duration=\"00:03:24\" title=\"\(title)\" artist=\"\(artist)\" album=\"\(album)\" status=\"\(status)\" type=\"\(type)\" imageUrl=\"\(imageURL)\"> <customFields></customFields> </playoutItem> </playoutData></onAir>"
        let parser = OnAirXMLDocumentParser(withString: xmlString)
        XCTAssertNotNil(parser, "parser should have a value because it is a non null object")
        
        parser?.delegate = self
        
        testExpectation = expectation(description: "parser should be able to parse non null input")
        parser?.parse()
        
        waitForExpectations(timeout: 10.0) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        XCTAssertNotNil(self.parsedDocument,"parsed document should have a value")
        XCTAssert(self.parsedDocument!.playoutItems.count == 1,"the document should have 1 playout item")
        
        let playoutItem = parsedDocument!.playoutItems.last!
        
        XCTAssertEqual(title, playoutItem.title, "item titles not matching")
        XCTAssertEqual(artist, playoutItem.artist, "item artists not matching")
        XCTAssertEqual(album, playoutItem.album, "item albums not matching")
        XCTAssertEqual(imageURL, playoutItem.imageURL, "item imageURLS not matching")
        XCTAssertTrue(playoutItem.status == .playing, "item status is not 'playing'")
        XCTAssertTrue(playoutItem.type == .song, "item type is not 'song'")
        XCTAssertTrue(playoutItem.customFields?.count == 0, "item should have 0 custom fields")
    }
    
    
    //MARK: OnAirDocumentParserDelegate methods
    func parser(parser: OnAirDocumentParser, didFinishWithParsingResult result: OnAirDocument?) {
        parsedDocument = result
        testExpectation?.fulfill()
    }
    
    func parser(parser: OnAirDocumentParser, didFailWithError error: Error?) {
        parsingError = error
        testExpectation?.fulfill()
    }
    
}
