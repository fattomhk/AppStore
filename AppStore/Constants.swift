//
//  Constants.swift
//  AppStore
//
//  Created by Horst Leung on 21/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation

struct Constants {
    struct API {
        static let pageSize = 10
        struct URL {
            static let listing : String = "https://itunes.apple.com/hk/rss/topfreeapplications/limit=100/json"
            static let detail : String = "https://itunes.apple.com/hk/lookup?id=%@"
            static let recommend : String = "https://itunes.apple.com/hk/rss/topgrossingapplications/limit=10/json"
        }
    }
}
