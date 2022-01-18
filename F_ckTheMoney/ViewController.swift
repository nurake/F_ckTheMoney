//
//  ViewController.swift
//  F_ckTheMoney
//
//  Created by nurake on 14.01.2022.
//

import UIKit
import RealmSwift


class ViewController: UIViewController {
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var spendingArray: Results<Spending>!
    var limitError: Results<Limit>!

    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howManyCanSpend: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var allSpending: UILabel!
    
    @IBOutlet var numberFromKeyboard: [UIButton]!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var stillTyping = false
    var categoryName = ""
    var displayValue = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(Spending.self)
        leftLabels()
        allSpendingFunc()
    }

//    Набор цифр в лейбле
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        if number == "0" && displayLabel.text == "0" {
            stillTyping = false
        } else {
            if stillTyping {
                if displayLabel.text!.count < 15 {
                    displayLabel.text = displayLabel.text! + number
                }
            } else {
                displayLabel.text = number
                stillTyping = true
            }
        }
    }
//    Кнопка сброса
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
//    Кнопка стирания последней цифры
    @IBAction func removeLastButton(_ sender: UIButton) {
        displayLabel.text?.removeLast()
        stillTyping = false
        
        if displayLabel.text == "" {
            displayLabel.text = "0"
            stillTyping = false
        }
    }
    
//    Выбор категории
    @IBAction func categoryPressed(_ sender: UIButton) {
        guard displayLabel.text != "0" else { return }
        
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
        }
        leftLabels()
        allSpendingFunc()
        tableView.reloadData()
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in
            
            let textFieldSum = alertController.textFields?[0].text
            
            let textFieldDay = alertController.textFields?[1].text
            
            guard textFieldDay != "" && textFieldSum != ""  else { return }
            self.limitLabel.text = textFieldSum
            
            if let day = textFieldDay {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                } else {
                    try! self.realm.write {
                        limit[0].limitSum = self.limitLabel.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDate = lastDay as NSDate
                    }
                }
            }
            self.leftLabels()
        }
        
        alertController.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
            
        let alertCancel = UIAlertAction(title: "Отмена", style: .default)
        
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func allSpendingFunc() {
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
    }
    
    func leftLabels() {
        let limit = self.realm.objects(Limit.self)
        
        guard limit.isEmpty == false else { return }
        
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDate as Date
        
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00") as Any
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any
        
        let filterLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")
        
        spendByCheck.text = "\(filterLimit)"
        
        let a = Int(limitLabel.text!)!
        let b = Int(spendByCheck.text!)!
        let c = a - b
        
        howManyCanSpend.text = "\(c)"
        
        allSpendingFunc()
    }
}


