//
//  PlayListInfo.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 08/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation
import UIKit

public class PlayListImageProvider : NSObject {

    static let ItemsChanged = "PlayListImageProvider.ItemsChanged"
    
    let baseUrl = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="
    let item : PlayListItem
    var items : [UIImage]? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(PlayListImageProvider.ItemsChanged, object: self)
        }
    }
    
    
    init(item : PlayListItem) {
        self.item = item
    }
    
    private func artistsSearchQuery() -> String {
        let str = "\(item.artist)-\(item.title)"
        return str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func titleSearchQuery() -> String {
        let str = "\(item.artist) \(item.title) song"
        return str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func defaultSearchQuery() -> String {
        let str = "jazzy radio"
        return str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public func searchForImages() {
        searchForDefaultImages { () -> Void in
            self.searchForArtistImages(){}
        }
    }
    
    private func searchForArtistImages(continuation: ()->Void) {
        let artistSrc = "\(baseUrl)\(artistsSearchQuery())"
        if let url = NSURL(string: artistSrc) {
            ImagesDownloader(url: url).download({ (images: [UIImage]?, error: NSError?) -> Void in
                if let error = error {
                    print("\(error)")
                    self.items = []
                    return
                }
                self.appendImages(images)
                continuation()
            })
        }
    }
    
    private func searchForDefaultImages(continuation: ()->Void) {
        let artistSrc = "\(baseUrl)\(defaultSearchQuery())"
        if let url = NSURL(string: artistSrc) {
            ImagesDownloader(url: url).download({ (images: [UIImage]?, error: NSError?) -> Void in
                if let error = error {
                    print("\(error)")
                    self.items = []
                    return
                }
                self.appendImages(images)
                continuation()
            })
        }
    }
    
    private func appendImages(images : [UIImage]?) {
        if let images = images {
            if self.items != nil {
                self.items! += images
            } else {
                self.items = images
            }
        }
    }
    
}
