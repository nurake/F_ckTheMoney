//
//  TableViewCell.swift
//  F_ckTheMoney
//
//  Created by nurake on 16.01.2022.
//

import UIKit
import RealmSwift

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var recordImage: UIImageView!
    @IBOutlet weak var recordCategory: UILabel!
    @IBOutlet weak var recordCost: UILabel!
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if spendingArray == nil {
            return spendingArray.count
        } else {
            return spendingArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let spending = spendingArray.reversed()[indexPath.row]
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
        case "Еда": cell.recordImage.image = UIImage.init(systemName: "cup.and.saucer.fill")
        case "Одежда": cell.recordImage.image = UIImage.init(systemName: "tshirt.fill")
        case "Связь": cell.recordImage.image = UIImage.init(systemName: "phone.fill")
        case "Досуг": cell.recordImage.image = UIImage.init(systemName: "crown.fill")
        case "Красота": cell.recordImage.image = UIImage.init(systemName: "leaf.fill")
        case "Авто": cell.recordImage.image = UIImage.init(systemName: "car.2.fill")
        default: cell.recordImage.image = UIImage.init(systemName: "stop.fill")
        }
        return cell
    }
//    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
//        return .delete
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let editingRow = spendingArray[indexPath.row]
        
        if editingStyle == .delete {
            try! realm.write {
                realm.delete(editingRow)
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            leftLabels()
            allSpendingFunc()
        }
    }
}
