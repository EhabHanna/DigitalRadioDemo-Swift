//
//  ListViewController.swift
//  DigitalRadioDemo-Swift
//
//  Created by Ehab Hanna on 8/7/17.
//  Copyright © 2017 Ehab Hanna. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var onAirTableView:UITableView!
    public var onAirDocument:OnAirDocument?
    
    private let epgCellIdentifier = "epgCell"
    private let playoutCellIdentifier = "playoutCell"
    private let headerCellIdentifier = "header"
    private var imageDownloadsInProgress = [IndexPath:IconDownloader]()
    private var downloadedImages = [IndexPath:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 
    //MARK: - UITableViewDatasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        
        sections = !(onAirDocument?.epgItems.isEmpty)! ? sections + 1 : sections
        sections = !(onAirDocument?.playoutItems.isEmpty)! ? sections + 1 : sections
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let epgs = onAirDocument?.epgItems.count ?? 0
        let playouts = onAirDocument?.playoutItems.count ?? 0
        
        return isRowEPGRow(atIndexPath: IndexPath(row: 0, section: section)) ? epgs : playouts
    }
    
    func isRowEPGRow(atIndexPath indexPath:IndexPath) -> Bool {
        return (indexPath.section == 0 && !(onAirDocument?.epgItems.isEmpty)!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isRowEPGRow(atIndexPath: indexPath) ? 100.0 : tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as? HeaderViewCell
        let title = isRowEPGRow(atIndexPath: IndexPath(row: 0, section: section)) ? "EPGs" : "Playouts"
        headerCell?.headerTitleLabel.text = title
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = isRowEPGRow(atIndexPath: indexPath) ? epgCellIdentifier : playoutCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! OnAirItemTableViewCell
        configure(itemCell: cell, atIndexPath: indexPath)
        return cell as! UITableViewCell
    }
    
    func configure(itemCell cell:OnAirItemTableViewCell, atIndexPath indexPath:IndexPath) {
        
        let item = onAirDocumentItem(atIndexPath: indexPath)
        let imageURL = imageURLString(forItem: item)
        
        cell.configure(with: item)
        
        if imageURL != nil {
            
            if let cellImage = downloadedImages[indexPath]{
                cell.update(image: cellImage)
            }else{
                if (self.onAirTableView.isDragging == false && self.onAirTableView.isDecelerating == false)
                {
                    self.startIconDownload(withURLString: imageURL, forIndexPath: indexPath)
                }
            }
            
        }else{
            cell.update(image: nil)
        }
    }
    
    //MARK: -
    //MARK: - Image support methods
    
    func startIconDownload(withURLString urlString:String?, forIndexPath indexPath:IndexPath) {
        
        if urlString != nil {
         
            let iconDownloader = imageDownloadsInProgress[indexPath]
            
            if iconDownloader == nil {
                
                let newIconDownloadr = IconDownloader(withImageURL: urlString!)
                
                weak var weakIconDownloader = newIconDownloadr
                
                newIconDownloadr.completionHandler = {
                    
                    let cell = self.onAirTableView.cellForRow(at: indexPath) as? OnAirItemTableViewCell
                    
                    if weakIconDownloader?.downloadedImage != nil {
                        
                        self.downloadedImages[indexPath] = weakIconDownloader?.downloadedImage!
                    }
                    
                    cell?.update(image: weakIconDownloader?.downloadedImage)
                    self.imageDownloadsInProgress.removeValue(forKey: indexPath)
                }
                self.imageDownloadsInProgress[indexPath] = newIconDownloadr
                newIconDownloadr.startDownload()
            }
            
        }
    }
    
    //MARK: -
    //MARK UIScrollViewDelegate methods
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenRows()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenRows()
    }
    
    func loadImagesForOnscreenRows() {
        
        if let visibleIndexPath = self.onAirTableView.indexPathsForVisibleRows{
            
            for indexPath in visibleIndexPath {
                
                let downloadedImage = self.downloadedImages[indexPath]
                if downloadedImage == nil {
                    self.startIconDownload(withURLString: imageURLString(forItem: onAirDocumentItem(atIndexPath: indexPath)) , forIndexPath: indexPath)
                }
            }
            
        }
    }
    
    func onAirDocumentItem(atIndexPath indexPath:IndexPath) -> onAirDocumentItem {
        
        if isRowEPGRow(atIndexPath: indexPath) {
            return onAirDocument!.epgItems[indexPath.row]
        }else{
            return onAirDocument!.playoutItems[indexPath.row]
        }
    }
    
    func imageURLString(forItem item:onAirDocumentItem) -> String? {
        
        if item is onAirEPGItem {
            return item.customFields?["image50"]
        }else{
            return (item as! onAirPlayoutItem).imageURL
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
