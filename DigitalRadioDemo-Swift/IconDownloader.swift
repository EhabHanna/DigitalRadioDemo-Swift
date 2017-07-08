//
//  IconDownloader.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 8/7/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class IconDownloader: NSObject {

    public var imageURLString:String
    public var downloadedImage:UIImage?
    
    typealias CompletionHandler = ()-> Void
    public var completionHandler:CompletionHandler?
    
    private var sessionTask:URLSessionDataTask?
    
    init(withImageURL imgURL:String) {
        
        imageURLString = imgURL
    }
    
    func startDownload () {
        
        if let request = URL(string: imageURLString){
         
            sessionTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let actualError = error as NSError? {
                    
                    if actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                        
                        abort()
                    }
                }
                
                if let theData = data {
                    
                    OperationQueue.main.addOperation {
                        
                        self.downloadedImage = UIImage(data: theData)
                        self.completionHandler?()
                        
                    }
                }
            })
            
            sessionTask?.resume()
        }
    }
    
    func cancelDownload () {
        sessionTask?.cancel()
        sessionTask = nil
    }
}
