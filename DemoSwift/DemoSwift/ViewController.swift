//
//  ViewController.swift
//  DemoSwift
//
//  Created by drif on 11/30/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

import UIKit
import StartSDK

class ViewController: UIViewController {
    
    @IBOutlet weak var numberTextField: UITextField?
    @IBOutlet weak var monthTextField: UITextField?
    @IBOutlet weak var yearTextField: UITextField?
    @IBOutlet weak var cvcTextField: UITextField?
    @IBOutlet weak var cardholderTextField: UITextField?
    @IBOutlet weak var errorsLabel: UILabel?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var textFields: [UITextField]?
    
    @IBOutlet weak var amountLabel: UILabel? {
        didSet {
            amountLabel?.text = "Pay \(amountString)"
        }
    }
    
    @IBAction func onPay(_ sender: UIButton) {
        pay()
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let _ = resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            numberTextField?.text = "4242424242424242";
            monthTextField?.text = "11";
            yearTextField?.text = "16";
            cvcTextField?.text = "123";
            cardholderTextField?.text = "John Smith";
        #endif
    }
    
    override func resignFirstResponder() -> Bool {
        textFields?.forEach { $0.resignFirstResponder() }
        return super.resignFirstResponder()
    }

    let amount = 100
    let currency = "USD"
    let start = Start(apiKey: "test_open_k_46dd87e36d3a5949aa68")

    var amountString: String {
        let amountNumber = NSNumber(floatLiteral: Double(amount) / 100)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amountNumber) ?? ""
    }

    var card: StartCard? {
        var card: StartCard?
        var errorString: String?
        
        do {
            let cardholder = cardholderTextField?.text ?? ""
            let number = numberTextField?.text ?? ""
            let cvc = cvcTextField?.text ?? ""
            let month = Int(monthTextField?.text ?? "") ?? 0
            let year = Int("20\(yearTextField?.text ?? "")") ?? 0

            card = try StartCard(cardholder: cardholder, number: number, cvc: cvc, expirationMonth: month, expirationYear: year)
        }
        catch let error as NSError {
            if let errors = error.userInfo[StartCardErrorKeyValues] as? [String] {
                errorString = "The following fields are invalid:"
                errors.forEach { errorString = "\(errorString ?? "")\n\($0)" }
            }
            else {
                errorString = "Unknown error occured"
            }
        }
        catch {
            errorString = "Unknown error occured"
        }
        
        errorsLabel?.text = errorString
        
        return card
    }

    func pay() {
        guard let card = card else {
            return
        }

        let _ = resignFirstResponder()

        activityIndicatorView?.startAnimating()
        start.createToken(for: card, amount: amount, currency: currency, successBlock: { token in
            self.showAlert(with: "Token ID received from server:\n\(token.tokenId)")
            self.activityIndicatorView?.stopAnimating()
        }, errorBlock: { error in
            self.showAlert(with: "Error occured:\n\(error)")
            self.activityIndicatorView?.stopAnimating()
        }, cancel: {
            self.showAlert(with: "Cancelled")
            self.activityIndicatorView?.stopAnimating()
        })
    }
    
    func showAlert(with text: String) {
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let controller = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
}
