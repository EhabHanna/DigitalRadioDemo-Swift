//
//  ViewController.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 28/6/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController,OnAirDocumentParserDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var parsingSuccessLabel: UILabel!
    
    private let onAirPath = "onAir"
    
    
    private enum ViewStatus{
        case fetchingOnAirSource, parsingOnAirSource, finishedParsing, failedParsing
    }
    
    private var viewStatus = ViewStatus.fetchingOnAirSource{
        didSet{
            updateViewContentsAccordingToStatus()
        }
    }
    private var onAirDocumentType = "xml"
    private var parsedDocument:OnAirDocument?
    private var onAirDocumentParser:OnAirXMLDocumentParser?
    
    private enum fetchingError:Error{
        case userActionError(title: String, message:String, actions:[(actionName:String,action:() -> Void)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getOnAirDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseOnAirData() {
        self.onAirDocumentParser?.delegate = self
        self.onAirDocumentParser?.parse()
        self.viewStatus = .parsingOnAirSource
    }
    
    //MARK:
    //MARK: onAirData Fetching
    func getOnAirDataSource() {
        var localCopyPath = URL(fileURLWithPath: getPathForCachedOnAirData())
        localCopyPath.appendPathComponent("onair", isDirectory: false)
        localCopyPath.appendPathExtension(onAirDocumentType)
        
        if FileManager.default.fileExists(atPath: localCopyPath.path) {
            
            onAirDocumentParser = OnAirXMLDocumentParser(withFile: localCopyPath.path)
            parseOnAirData()
        }else{
            do {
                try fetchOnAirDataFromInternet()
            } catch let error as fetchingError {
                self.handleError(error: error)
            }catch {
                print("Something went wrong with fetching")
            }
            
        }
    }
    
    func getPathForCachedOnAirData() -> String{
        
        let searchPaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let myPathString = searchPaths.first!
        
        let myPath = URL(fileURLWithPath: myPathString).appendingPathComponent(onAirPath)
        
        var isDir : ObjCBool = false
        if !(FileManager.default.fileExists(atPath: myPath.path, isDirectory:&isDir)) {
           
            do {
                try FileManager.default.createDirectory(at: myPath, withIntermediateDirectories: true, attributes: nil)
            } catch { print("could not create directory at cache path")}
        }
        return myPath.path
    }
    
    func saveOnAirDataToDisk(with file:Data) {
        
        var localCopyPath = URL(fileURLWithPath: getPathForCachedOnAirData())
        localCopyPath.appendPathComponent("onair", isDirectory: false)
        localCopyPath.appendPathExtension(onAirDocumentType)
        
        do {
            try file.write(to: localCopyPath)
        } catch { print("could not save xml file to disk")}
        
    }
    
    func deleteCachedOnAirData() {
        
        var localCopyPath = URL(fileURLWithPath: getPathForCachedOnAirData())
        localCopyPath.appendPathComponent("onair", isDirectory: false)
        localCopyPath.appendPathExtension(onAirDocumentType)

        do {
            try FileManager.default.removeItem(at: localCopyPath)
        } catch { print("could not delete xml file from disk")}
        
    }
    
    func fetchOnAirDataFromInternet() throws {
        
        if Reachability()?.currentReachabilityStatus != .notReachable {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            viewStatus = .fetchingOnAirSource
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                
                if let data = try? Data(contentsOf: URL(string: "http://aim.appdata.abc.net.au.edgesuite.net/data/abc/triplej/onair.xml")!){
                    
                    self.saveOnAirDataToDisk(with: data)
                    
                    DispatchQueue.main.async {
                        self.onAirDocumentParser = OnAirXMLDocumentParser(withData: data)
                        
                        if self.onAirDocumentParser != nil {
                            self.parseOnAirData()
                        }else{
                            self.handleError(error: fetchingError.userActionError(title: "Data Retreival Error", message: "Server returned empty data, what would you like to do?", actions: [(actionName:"Retry",{ self.getOnAirDataSource() }),(actionName:"Exit",{ exit(0) })]))
                        }
                    }
                    
                }else{
                    
                    self.handleError(error: fetchingError.userActionError(title: "Data Retreival Error", message: "App could not retreive data from server, server may be experiencing issues. What would you like to do?", actions: [(actionName:"Retry",{ self.getOnAirDataSource() }),(actionName:"Exit",{ exit(0) })]))
                }
                
            }
            
        }else{
            //show no connection alert
            throw fetchingError.userActionError(title: "No Internet Connection", message: "Your device is not connected to the internet. Please check your connection and try again", actions: [(actionName:"Retry",{ self.getOnAirDataSource() }),(actionName:"Exit",{ exit(0) })])
        }
        
    }
    
    //MARK: error handling
    private func handleError(error:fetchingError) {
        
        switch error {
        case .userActionError(let title,let message,let actions):
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            for (actionName,action) in actions {
                alertController.addAction(UIAlertAction(title: actionName, style: .default, handler: { (UIAlertAction) in
                    action()
                }))
            }
         
        }
    }
    
    //MARK: updating View Contents
    func updateViewContentsAccordingToStatus (){
        
        switch (self.viewStatus) {
        case .fetchingOnAirSource:
            self.loadingLabel.text = "Fetching Data..."
            self.activityIndicator.startAnimating()
            self.loadingLabel.isHidden = false
            self.parsingSuccessLabel.isHidden = true
            break
            
        case .parsingOnAirSource:
        
            self.loadingLabel.text = "Parsing Data..."
            self.activityIndicator.startAnimating()
            self.loadingLabel.isHidden = true
            self.parsingSuccessLabel.isHidden = true
            break
            
        case .finishedParsing:
            self.loadingLabel.text = "Data Parsed"
            self.activityIndicator.stopAnimating()
            self.loadingLabel.isHidden = true
            self.parsingSuccessLabel.isHidden = true
            break
            
        case .failedParsing:
            self.loadingLabel.isHidden = true
            self.activityIndicator.stopAnimating()
            self.parsingSuccessLabel.isHidden = true
            break
            
        }

        
    }
    
    //MARK: onAirDocumentParserDelegate methods
    func parser(parser: OnAirDocumentParser, didFailWithError error: Error?) {
     
        viewStatus = .failedParsing
        self.handleError(error: fetchingError.userActionError(title: "Data Parsing Failed", message: "App could falset parse on air data and cannot continue. What would you like to do?", actions: [(actionName:"Retry",{ self.deleteCachedOnAirData(); self.getOnAirDataSource() }),(actionName:"Exit",{ exit(0) })]))
    }
    
    func parser(parser: OnAirDocumentParser, didFinishWithParsingResult result: OnAirDocument?) {
        self.viewStatus = .finishedParsing
        self.parsedDocument = result
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            self.performSegue(withIdentifier: "onAirTableView", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "onAirTableView" {
            
            let listViewController = segue.destination as! ListViewController
            listViewController.onAirDocument = self.parsedDocument!
        }
    }

}

