//
//  AppDetail.swift
//  AppStore
//
//  Created by Horst 梁峻浩 on 22/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import JustJson

class AppDetail: JJMappable{
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
    var rating: Double = 0
    var ratingCount: Int = 0
    var author: String
    var rank: Int?
    
    required init(map: JJMapper) {
        id = String(map[intValue: "trackId"])
        bundleId = map[string: "bundleId"] ?? ""
        name = map[string: "trackName"] ?? ""
        summary = map[string: "description"] ?? ""
        price = map[floatValue: "price"]
        currency = map[string: "currency"] ?? ""
        priceLabel = map[string: "formattedPrice"] ?? ""
        link = map[string: "trackViewUrl"] ?? ""
        category = map[string: "primaryGenreName"] ?? ""
        rating = map[doubleValue: "averageUserRating"]
        ratingCount = map[intValue: "userRatingCount"]
        author = map[string: "artistName"] ?? ""
        if let dateStr = map[string: "releaseDate"] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            releaseDate = dateFormatter.date(from: dateStr) ?? Date()
        }
        
        if let imgURL = map[string: "artworkUrl100"] {
            self.imageURL = imgURL
        }
    }
    
//    init(id _id: String,
//         bundleId _bundleId: String,
//         name _name: String,
//         summary _summary: String,
//         price _price: Float,
//         currency _currency: String,
//         priceLabel _priceLabel: String,
//         link _link: String,
//         category _category: String,
//         author _author: String) {
//        self.id = _id
//        self.bundleId = _bundleId
//        self.name = _name
//        self.summary = _summary
//        self.price = _price
//        self.currency = _currency
//        self.priceLabel = _priceLabel
//        self.link = _link
//        self.category = _category
//        self.author = _author
//        self.rating = 0
//        self.ratingCount = 0
//    }
    
    func search(by query: String) -> Bool {
        guard query.isEmpty == false else {
            return true
        }
        let q = query.lowercased()
        return author.lowercased().contains(q) || summary.lowercased().contains(q) || category.lowercased().contains(q) || name.lowercased().contains(q)
    }
}
