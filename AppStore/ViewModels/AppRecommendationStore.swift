//
//  AppListViewModel.swift
//  AppStore
//
//  Created by Horst Leung on 21/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import JustJson

class AppRecommendationStore {
    let disposeBag = DisposeBag();
    var searchQuery: Variable<String> = Variable(String())
    var originList: [App] = [App]()

    lazy var appRecommendationList: Variable<[App]> = {[unowned self] in
        self.getList()
        return Variable([App]())
    }()
    
    func fetchAppList() -> Observable<[App]> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(Constants.API.URL.recommend)
                .responseString(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        if let json = response.result.value?.toDictionary(),
                            let apps = App.from(json[arrayValue: "feed.entry"]) {
                            observer.onNext(apps)
                        }
                        observer.onCompleted()
                        break
                    case .failure(let error):
                        observer.onError(error)
                        break
                    }
                })
            return Disposables.create()
        })
    }
    
    func getList() {
        self.fetchAppList()
        .flatMap{ Observable.from($0) }
        .subscribe(onNext: {[weak self] (results: [App]) in
            self?.originList = results
            self?.appRecommendationList.value = results
        })
        .addDisposableTo(disposeBag)
    }
    
    func search(by query: String) {
        if query.isEmpty && !self.originList.isEmpty {
            self.appRecommendationList.value = self.originList
        }
        
        if query.isEmpty == false {
            self.appRecommendationList.value = self.originList.filter({ (app) -> Bool in
                return app.search(by: query)
            })
        }
        
    }
}



