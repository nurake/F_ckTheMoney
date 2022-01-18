//
//  SpendingModel.swift
//  F_ckTheMoney
//
//  Created by nurake on 16.01.2022.
//

import RealmSwift
import Foundation

class Spending: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
}

class Limit: Object {
    @objc dynamic var limitSum = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var limitLastDate = NSDate()
}
