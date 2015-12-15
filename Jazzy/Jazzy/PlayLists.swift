//
//  PlayListItem.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 07/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation


public class PlayListItem : NSObject {
  
    let date : NSDate
    let title : String
    let artist : String

    init(date : NSDate, title : String, artist : String) {
        self.date = date
        self.title = title
        self.artist = artist
    }
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? PlayListItem {
            return title == rhs.title && artist == rhs.artist
        }
        return false
    }
}

class PlayListParser {
    
    let string : String
    let dateFormatter = NSDateFormatter()
    
    init(data: NSData) {
        self.string = String(data: data, encoding: NSUTF8StringEncoding)!
        self.dateFormatter.dateFormat = "HH:mm"
        self.dateFormatter.defaultDate = NSDate()
    }
    
    func parse() -> [PlayListItem] {

        let regexp = try! NSRegularExpression(pattern: "<td>(.*)</td>\n *<td>(.*)</td>\n *<td>(.*)</td>", options: NSRegularExpressionOptions.CaseInsensitive)
        let matches = regexp.matchesInString(string, options: NSMatchingOptions.ReportProgress, range: NSRange(location: 0, length: string.characters.count))

        var items = [PlayListItem]()
        let nsString: NSString = string as NSString
        for match in matches {
            if match.numberOfRanges == 4 {
                let dataStr = nsString.substringWithRange(match.rangeAtIndex(1))
                let artist = nsString.substringWithRange(match.rangeAtIndex(2))
                let title = nsString.substringWithRange(match.rangeAtIndex(3))
                let item = PlayListItem(date: dateFormatter.dateFromString(dataStr)!, title: title, artist: artist)
                items.append(item)
            }
        }
        return items
    }
}


class PlayListDownloader {
    
    let url : NSURL
    var maxCount = 10
    
    init(url: NSURL) {
        self.url = url
    }
    
    func download(completion : ([PlayListItem]?, NSError?) -> Void) {
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
    
    private func items(data: NSData) -> [PlayListItem] {
        let parser = PlayListParser(data: data)
        let allItems = parser.parse().sort ({
            $0.date.compare($1.date) == NSComparisonResult.OrderedDescending
        })
        var items = [PlayListItem]()
        for var i = 0; i < min(self.maxCount, allItems.count); i++ {
            items.append(allItems[i])
        }
        return items
    }
}

public class PlayListUpdater : NSObject {

    let ItemChangedNotification = "PlayListItemChanged"
    let updatePeriod = 15.0
    var currentPlayListItem : PlayListItem?
    var timer : NSTimer?
    let downloader : PlayListDownloader
    
    init(url: NSURL) {
        self.downloader = PlayListDownloader(url: url)
    }
    
    public func startUpdate() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if self.timer == nil {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(self.updatePeriod, target: self, selector:"onTimer:", userInfo: nil, repeats: false)
            }
        }
    }
    
    public func stopUpdate() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    private func restartTimer() {
        if self.timer != nil {
            self.timer = nil
            startUpdate()
        }
    }
    
    func onTimer(timer:NSTimer!) {
        doUpdate()
    }
    
    private func doUpdate() {
        downloader.download { (items: [PlayListItem]?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error downloading playlist \(error)")
                return;
            }
            self.processPlayList(items)
            self.restartTimer()
        }
    }
    
    private func processPlayList(items: [PlayListItem]?) {
        
        let item = valid(items?.first)
        if currentPlayListItem != item {
            currentPlayListItem = item
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ItemChangedNotification, object: currentPlayListItem))
        }
    }
    
    private func valid(item: PlayListItem?) -> PlayListItem? {
        if let item = item {
            if item.date.timeIntervalSinceNow > -450 {
                return item
            }
        }
        return nil;
    }
}


