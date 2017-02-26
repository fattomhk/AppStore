//
//  AppListCell.swift
//  AppStore
//
//  Created by Horst 梁峻浩 on 22/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class AppListCell: UITableViewCell {
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
}
