//
//  ViewController.swift
//  MyStocks
//
//  Created by Roman Kochnev on 27/01/2019.
//  Copyright © 2019 Roman Kochnev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - IBOutlets

    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - IBActions
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Hello, dear user", message: "In this application you can get information about companies that are listed on the stock exchange.", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - private properties
    
    private let companies: [String: String] = ["Apple": "AAPL",
                                               "Microsoft": "MSFT",
                                               "Google": "GOOG",
                                               "Amazon": "AMZN",
                                               "Facebook": "FB",
                                               "Tesla": "TSLA"]
    
    // MARK: - private methods
    
    private func requestQuote(for symbol:String) {
        let url = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/quote")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
        guard
            error == nil,
            (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
            else {
                let alertController = UIAlertController(title: "Sorry", message: "Network error!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                //print("Network error!")
                return
            }
            
            self.parseQuote(data: data)
        }
        
        dataTask.resume()
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
            let json = jsonObject as? [String: Any],
            let companyName = json["companyName"] as? String,
            let companySymbol = json["symbol"] as? String,
            let exchange = json["primaryExchange"] as? String,
            let sector = json["sector"] as? String,
            let price = json["latestPrice"] as? Double,
            let priceChange = json["change"] as? Double
                else {
                    let alertController = UIAlertController(title: "", message: "Invalid JSON format", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    //print("Invalid JSON format")
                    return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      exchange: exchange,
                                      sector: sector,
                                      price: price,
                                      priceChange: priceChange)
            }
        } catch {
            let alertController = UIAlertController(title: "", message: "! JSON parsing error: \(error.localizedDescription)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
           // print("! JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, exchange: String, sector: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.exchangeLabel.text = exchange
        self.industryLabel.text = sector
        self.priceLabel.text = "\(price)"
        if (price < 0) {
        self.priceChangeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        } else {
        self.priceChangeLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        }
        self.priceChangeLabel.text = "\(priceChange)"
    }
    
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.exchangeLabel.text = "-"
        self.industryLabel.text = "-"
        self.priceLabel.text = "-"
        
        self.priceChangeLabel.text = "-"
        self.priceChangeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }
    
    // MARK: - View lifestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.companyNameLabel.text = "Tinkoff"
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
//        self.activityIndicator.startAnimating()
//        self.requestQuote(for: "AAPL")
        
        self.requestQuoteUpdate()
    }

    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
}

