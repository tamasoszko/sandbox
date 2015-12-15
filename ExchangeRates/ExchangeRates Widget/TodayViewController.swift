//
//  TodayViewController.swift
//  ExchangeRates Widget
//
//  Created by Oszkó Tamás on 21/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding, JBLineChartViewDataSource, JBLineChartViewDelegate {
        
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var chartView: JBLineChartView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var rates: [Rate]?
    let tintColor = UIColor(red: 178/255, green: 211/255, blue: 240/255, alpha: 1)
    
    var ratesDownloader: RatesDownloader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.dataSource = self
        chartView.delegate = self
//        chartView.minimumValue = 0
        
        segmentedControl.setTitle("EUR", forSegmentAtIndex: 0)
        segmentedControl.setTitle("NOK", forSegmentAtIndex: 1)
        
        activityIndicator.color = tintColor // .tintColor = tintColor
        segmentedControl.tintColor = tintColor
        rateLabel.textColor = tintColor
        detailLabel.textColor = tintColor
        
        detailLabel.text = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        refreshRates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        refreshRates()
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        guard let rates = rates else {
            return 0
        }
        return UInt(rates.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        let index = Int(horizontalIndex)
        let rate = rates![index]
        return CGFloat(rate.value.floatValue)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return tintColor
    }
    
    public func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 1.0
    }
    
    private func refreshRates() {
        
        ratesDownloader = createRatesDownloader()
        rates?.removeAll()
        chartView.hidden = true
        
        activityIndicator.startAnimating()
        rateLabel.text = ""
        rateLabel.textColor = self.tintColor
        detailLabel.text = ""
        
        ratesDownloader?.getRates({ (rates: [Rate]?, updated: NSDate?, error: NSError?) -> () in
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.detailLabel.text = "Refresh error \(error.localizedDescription)"
                return
            }
            self.chartView.hidden = false
            let df = NSDateFormatter()
            df.dateFormat = "MM/dd HH:mm"
            self.detailLabel.text = "Last updated \(df.stringFromDate(updated!))"
            self.rates = rates
            self.chartView.reloadData()
            
            if let lastRate = rates!.first {
                self.rateLabel.text = "\(lastRate.value)\(lastRate.currencyTo)"
                if rates?.count > 1 {
                    let lastRate2 = rates![1]
                    let cmp = lastRate.value.compare(lastRate2.value)
                    if cmp == NSComparisonResult.OrderedDescending {
                        self.rateLabel.textColor = UIColor.greenColor()
                    } else if cmp == NSComparisonResult.OrderedAscending {
                        self.rateLabel.textColor = UIColor.redColor()
                    } else {
                        self.rateLabel.textColor = self.tintColor
                    }
                }
            }
        })
    }
    
    private func createRatesDownloader() -> RatesDownloader {

        var currency: String?
        if segmentedControl.selectedSegmentIndex == 0 {
            currency = "EUR"
        } else {
            currency = "NOK"
        }
        return MNBRatesDownloader(currency: currency!)
    }
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        refreshRates()
    }
    
}
