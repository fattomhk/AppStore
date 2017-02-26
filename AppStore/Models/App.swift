//
//  App.swift
//  AppStore
//
//  Created by Horst Leung on 21/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import JustJson

class App: JJMappable{
    var id: String
    var bundleId: String
    var name: String
    var imageURL: String?
    var summary: String
    var price: Float
    var currency: String
    var priceLabel: String
    var link: String
    var category: String
    var releaseDate: Date?
    var rating: Float = 0
    var author: String
    
    required init(map: JJMapper) {
        id = map[string: "id.attributes.im:id"] ?? ""
        bundleId = map[string: "id.attributes.im:bundleId"] ?? ""
        name = map[string: "im:name.label"] ?? ""
        summary = map[string: "summary.label"] ?? ""
        price = map[floatValue: "im:price.attributes.amount"]
        currency = map[string: "im:price.attributes.currency"] ?? ""
        priceLabel = map[string: "im:price.label"] ?? ""
        link = map[string: "link.attributes.href"] ?? ""
        category = map[string: "category.attributes.label"] ?? ""
        author = map[string: "im:artist.label"] ?? ""
        if let dateStr = map[string: "im:releaseDate.label"] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            releaseDate = dateFormatter.date(from: dateStr) ?? Date()
        }
        
        if let img = map[arrayValue: "im:image"].last as? [String: Any] {
            self.imageURL = img[string: "label"]
        }
    }
    
    func search(by query: String) -> Bool {
        guard query.isEmpty == false else {
            return true
        }
        let q = query.lowercased()
        return author.lowercased().contains(q) || summary.lowercased().contains(q) || category.lowercased().contains(q) || name.lowercased().contains(q)
    }
}

