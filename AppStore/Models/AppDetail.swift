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
    
    required init(map: JJMapper) {
        
        id = map[string: "trackId"] ?? ""
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
    
    func search(by query: String) -> Bool {
        guard query.isEmpty == false else {
            return true
        }
        let q = query.lowercased()
        return author.lowercased().contains(q) || summary.lowercased().contains(q) || category.lowercased().contains(q) || name.lowercased().contains(q)
    }
}
