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
import APESuperHUD

class AppListStore {
    let disposeBag = DisposeBag();
    var appPool: [AppDetail] = []
    var searchQuery: Variable<String> = Variable(String())
    var originList: [AppDetail] = [AppDetail]()
    var errorMsg: Variable<String> = Variable(String())
    var appRank = [String]()
    
    var shouldShowLoading: Bool = false {
        didSet {
            if let mainWindow = UIApplication.shared.keyWindow?.subviews.last {
                if shouldShowLoading {
                    APESuperHUD.showOrUpdateHUD(loadingIndicator: .standard, message: "", presentingView: mainWindow)
                } else {
                    APESuperHUD.removeHUD(animated: true, presentingView: mainWindow, completion: { _ in
                        // Completed
                    })
                }
                
            }
            
        }
    }

    lazy var appList: Variable<[AppDetail]> = {[unowned self] in
        self.getList()
        return Variable([AppDetail]())
    }()
    
    func fetchAppList() -> Observable<[App]> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(Constants.API.URL.listing)
                .responseString(completionHandler: {[weak self] (response) in
                    switch response.result {
                    case .success:
                        if let json = response.result.value?.toDictionary(),
                            let apps = App.from(json[arrayValue: "feed.entry"]) {
                            self?.appRank = apps.map({ (app) -> String in
                                return app.id
                            })
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
    
    func fetchAppDetail(appId: String) -> Observable<AppDetail> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(String(format: Constants.API.URL.detail, appId))
                .responseString(completionHandler: { (response) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    switch response.result {
                    case .success:
                        if let json = response.result.value?.toDictionary(),
                        let res = json[arrayValue: "results"].first as? [String: Any],
                        let appDetail = AppDetail.from(res){
                            observer.onNext(appDetail)
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
        self.shouldShowLoading = true
        self.fetchAppList()
        .flatMap{ Observable.from($0) }
        .map{ $0.id }
        .flatMap(fetchAppDetail)
        .filter {
            self.searchQuery.value.isEmpty ? true : $0.search(by: self.searchQuery.value)
        }
        .toArray()
        .subscribe(onNext: {[weak self] (results: [AppDetail]) in
            self?.appPool = self?.appRank.enumerated().map({ (index, appId) -> AppDetail in
                let detail = results.filter{return $0.id == appId}.first
                detail?.rank = index + 1
                return detail!
            }) ?? []
            
            if results.count >= Constants.API.pageSize {
                self?.appList.value = Array(results[0...Constants.API.pageSize-1])
            } else if results.count > 0 {
                self?.appList.value = Array(results[0...results.count-1])
            }
        }, onError: {[weak self] (error) in
            self?.errorMsg.value = error.localizedDescription
        }, onCompleted: {
            self.shouldShowLoading = false
        })
        .addDisposableTo(disposeBag)
    }
    
    func loadMore(reload: Bool = false) {
        guard appPool.count > appList.value.count else {
            return
        }
        
        guard self.searchQuery.value.isEmpty else {
            return
        }
        
        let startIdx = reload ? 0 : appList.value.count
        var endIdx = startIdx + Constants.API.pageSize - 1
        if endIdx > appPool.count - 1 {
            endIdx = appPool.count - 1
        }
        
        let data = Array(appPool[startIdx...endIdx])
        appList.value = appList.value + data
    }
    
    func search(by query: String) {
        if query.isEmpty {
            appList.value = []
            loadMore(reload: true)
        } else {
            appList.value = []
            self.appList.value = self.appPool.filter({ (appDetail) -> Bool in
                return appDetail.search(by: query)
            })
        }
        
    }
}



