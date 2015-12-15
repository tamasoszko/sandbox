//
//  ViewController.swift
//  ExchangeRates
//
//  Created by Oszkó Tamás on 21/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate {

    @IBOutlet weak var chartView: JBLineChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var changeLabel: UILabel!
    
    var ratesDownloader: RatesDownloader?
    var rates: [Rate]?
    let color = UIColor(red: 23/255, green: 109/255, blue: 250/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        chartView.dataSource = self
        chartView.delegate = self
        
        segmentedControl.setTitle("EUR", forSegmentAtIndex: 0)
        segmentedControl.setTitle("NOK", forSegmentAtIndex: 1)
        
        
        segmentedControl.tintColor = color
        rateLabel.textColor = color
        updatedLabel.textColor = color
        activityIndicator.tintColor = color
        
        refreshRates()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }


    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            refreshRates()
        }
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
        return color
    }
    
    public func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 1.0
    }
    
    private func refreshRates() {
        
        ratesDownloader = createRatesDownloader()
        rates?.removeAll()
        chartView.reloadData()

        activityIndicator.startAnimating()
        rateLabel.text = "-"
        changeLabel.text = "-"
        changeLabel.textColor = self.color
        updatedLabel.text = "Refreshing..."
        ratesDownloader?.getRates({ (rates: [Rate]?, updated: NSDate?, error: NSError?) -> () in
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.updatedLabel.text = "Refresh error \(error.localizedDescription)"
                return
            }
            let df = NSDateFormatter()
            df.dateFormat = "MM/dd HH:mm"
            self.updatedLabel.text = "Updated at \(df.stringFromDate(updated!))"
            self.rates = rates
            self.chartView.reloadData()
            
            let lastRate = rates![0]
            self.rateLabel.text = "\(lastRate.value)\(lastRate.currencyTo)"
            if rates?.count > 1, let last2Rate = rates?[1] {
                let chg = lastRate.value.floatValue - last2Rate.value.floatValue
                if chg < 0 {
                    self.changeLabel.textColor = UIColor.redColor()
                    self.changeLabel.text = "\(chg)"
                } else if chg > 0 {
                    self.changeLabel.textColor = UIColor.greenColor()
                    self.changeLabel.text = "+\(chg)"
                } else {
                    self.changeLabel.textColor = self.color
                    self.changeLabel.text = "0.0"
                }
            }
        })
    }
    
    private func createRatesDownloader() -> RatesDownloader {

        let currency = segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex)
        return MNBRatesDownloader(currency: currency!)
    }
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        refreshRates()
    }
}

