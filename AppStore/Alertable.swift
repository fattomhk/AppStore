//
//  Alertable.swift
//  AppStore
//
//  Created by Horst 梁峻浩 on 23/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import UIKit
protocol Alertable {
    func alert(title: String? , msg: String)
}

extension Alertable where Self: UIViewController {
    func alert(title: String? = nil, msg: String) {
        let alert = UIAlertController(title: title ?? "Problem", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
