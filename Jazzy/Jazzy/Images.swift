//
//  Downloader.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 07/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation
import UIKit


class ImageParser {
    
    let json : AnyObject?
    let dateFormatter = NSDateFormatter()
    
    init(data: NSData) {
        self.json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        self.dateFormatter.dateFormat = "HH:mm"
        self.dateFormatter.defaultDate = NSDate()
    }
    func parse() -> [NSURL] {
        
        if self.json == nil {
            return []
        }
        var items = [NSURL]()
        if let responseData = json!["responseData"] as? NSDictionary {
            if let results = responseData["results"] as? [NSDictionary] {
                print(results)
                for result in results {
                    if let url = result["url"] as? String {
                        items.append(NSURL(string: url)!)
                    }
                }
            }
        }
        return items
    }
}


public class ImagesDownloader : NSObject {
    
    let url : NSURL
    var maxCount = 10
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public func download(completion : ([UIImage]?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url) { (_data: NSData?, _resp: NSURLResponse?, _error: NSError?) -> Void in
            if let error = _error {
                completion(nil, error)
                return
            }
            completion(self.items(_data!), nil)
        }
        task.resume()
    }
    
    private func items(data: NSData) -> [UIImage] {
        
        let parser = ImageParser(data: data)
        let allItems = parser.parse()
        
        var items = [UIImage]()
        for var i = 0; i < min(self.maxCount, allItems.count); i++ {
            if let imgData = NSData(contentsOfURL: allItems[i]) {
                if let image = UIImage(data: imgData) {
                    items.append(image)
                }
            }
        }
        return items
    }
}
