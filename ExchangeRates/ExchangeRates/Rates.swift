//
//  RatesDownloader.swift
//  ExchangeRates
//
//  Created by Oszkó Tamás on 21/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation

final class Rate {
    
    let currencyFrom: String
    let currencyTo: String
    let value: NSNumber
    let date: NSDate
    
    init(currencyFrom: String, currencyTo: String, value: NSNumber, date: NSDate) {
        self.currencyFrom = currencyFrom
        self.currencyTo = currencyTo
        self.value = value
        self.date = date
    }
}

protocol RatesDownloader {
 
    func getRates(completion:([Rate]?, NSDate?, NSError?)->())
    
}

class RandomRatesDownloader : RatesDownloader {

    let currencyFrom: String
    let base: Int
    let chg: Int
    
    init(currencyFrom: String, base: Int, chg: Int) {
        self.currencyFrom = currencyFrom
        self.base = base
        self.chg = chg
    }
    
    func getRates(completion:([Rate]?, NSDate?, NSError?)->()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            var rates = [Rate]()
            for var i = 0; i < 30; i++ {
                rates.append(self.randomRate())
            }
            sleep(2)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                completion(rates, NSDate(), nil)
            }
        }
    }
    
    private func randomRate() -> Rate {
        let valInt = Int(arc4random_uniform(UInt32(chg))) + base
        let valFrac = Int(arc4random_uniform(UInt32(100)))
        let floatVal = Float(valInt) + Float(valFrac)/100
        let value = NSNumber(float: floatVal)
        return Rate(currencyFrom: currencyFrom, currencyTo: "HUF", value: value, date: NSDate())
    }
    
}

class MNBRatesDownloader : RatesDownloader {

    let currency: String
    let lastModifiedKey: String
    let ratesKey: String
    let cacheMaxAge = 3600 * 4
    
    init(currency: String) {
        self.currency = currency
        lastModifiedKey = "LastModified-\(currency)"
        ratesKey = "Rates-\(currency)"
    }
    
    func getRates(completion:([Rate]?, NSDate?, NSError?)->()) {
        
        let res = loadFromCache(cacheMaxAge)
        if let data = res.data, let lastModified = res.lastModified {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(self.parse(data), lastModified, nil)
            })
            return
        }
        let session = NSURLSession.sharedSession()
        let url = getUrl()
        let task = session.dataTaskWithURL(url) { (_data: NSData?, _resp: NSURLResponse?, _error: NSError?) -> Void in
            if let error = _error {
                completion(nil, nil, error)
                return
            }
            self.saveToCache(_data)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(self.parse(_data!), NSDate(), nil)
            })
        }
        task.resume()
    }
    
    private func loadFromCache(maxAge: Int) -> (data: NSData?, lastModified: NSDate?) {
        let lastModified = NSUserDefaults.standardUserDefaults().objectForKey(lastModifiedKey)
        let rates = NSUserDefaults.standardUserDefaults().objectForKey(ratesKey)
        guard lastModified != nil && rates != nil && lastModified?.timeIntervalSinceNow > Double(-1*maxAge) else {
            return (nil, nil)
        }
        return (rates as? NSData, lastModified as? NSDate)
    }
    
    private func saveToCache(data: NSData?) {
        guard let data = data else {
            return
        }
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: lastModifiedKey)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: ratesKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func getUrl() -> NSURL {
        
        let to = NSDate()
        let from = NSDate(timeIntervalSinceNow: -3600 * 24 * 90)
        let df = NSDateFormatter()
        df.dateFormat = "YYYY.MM.dd"
        
        let urlStr = "https://www.mnb.hu/arfolyam-tablazat?deviza=rbCurrencySelect&devizaSelected=\(currency)&datefrom=\(df.stringFromDate(from)).&datetill=\(df.stringFromDate(to)).&order=0"
        return NSURL(string: urlStr)!
    }
    
    func parse(data: NSData) -> [Rate] {
        
        let string = String(data: data, encoding: NSUTF8StringEncoding)!
        let regexp = try! NSRegularExpression(pattern: "<td class=\"rotate\"><div><span>(.*)</span></div></td>", options: NSRegularExpressionOptions.CaseInsensitive)
        let matches = regexp.matchesInString(string, options: NSMatchingOptions.ReportProgress, range: NSRange(location: 0, length: string.characters.count))
        
        var items = [Rate]()
        let nsString: NSString = string as NSString
        guard matches.count % 2 == 0 else {
            return [Rate]()
        }
        let nf = NSNumberFormatter()
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        nf.decimalSeparator = "."
        for var i = 0; i < matches.count/2; i++ {
            let matchDate = matches[i * 2]
            let matchRate = matches[i * 2 + 1]
            guard matchDate.numberOfRanges == 2
                && matchRate.numberOfRanges == 2 else {
                    continue
            }
            let dateStr = nsString.substringWithRange(matchDate.rangeAtIndex(1))
            let rateStr = nsString.substringWithRange(matchRate.rangeAtIndex(1)).stringByReplacingOccurrencesOfString(",", withString: ".")
            let rate = Rate(currencyFrom: currency, currencyTo: "HUF", value: nf.numberFromString(rateStr)!, date: NSDate(timeIntervalSinceNow: -3600 * 24 * Double(i)))
            items.append(rate)
        }
        return items
    }
}