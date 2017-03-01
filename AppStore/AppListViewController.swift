//
//  AppListViewController.swift
//  AppStore
//
//  Created by Horst 梁峻浩 on 22/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Kingfisher
import MXParallaxHeader
import Alamofire

class AppListViewController: UIViewController, Alertable, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    let manager = NetworkReachabilityManager(host: "www.apple.com")
    var needResume = true

    var viewModel: AppListStore = AppListStore()
    var loadedAppDetailCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager?.listener = {[weak self] status in
            print(status)
            if status == .notReachable {
                //no network
                self?.needResume = true
                self?.showNetworkError()
            } else if status != .unknown  && self?.needResume ?? false {
                self?.needResume = false
                if self?.viewModel.appPool.count == 0 {
                    self?.viewModel.getList()
                }
            }
        }
        
        manager?.startListening()
        
        self.setupTableView()
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppRecommendationListViewController") as? AppRecommendationListViewController {
            self.addChildViewController(vc)
            var bounds = self.view.bounds
            bounds.size.height = 220
            
            vc.view.frame = bounds
            vc.view.autoresizingMask = .flexibleWidth
            vc.didMove(toParentViewController: self)
            
            tableView.parallaxHeader.view = vc.view
            tableView.parallaxHeader.height = vc.view.bounds.height
            tableView.parallaxHeader.mode = .fill
            
        }
        
        viewModel.errorMsg.asObservable().subscribe(onNext: { (errorMsg) in
            if errorMsg.isEmpty == false {
                
            }
        }).addDisposableTo(disposeBag)
        
        viewModel.searchQuery.asObservable()
            .subscribe(onNext: {[weak self] (query) in
                self?.viewModel.search(by: query)
            })
            .addDisposableTo(disposeBag)
    }
    
    static func shouldLoadMore(contentOffset: CGPoint,  tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + 30 > tableView.contentSize.height
    }
    
    func showNetworkError() {
        self.alert(msg: "The Internet connection appears to be offline.")
    }
    
    func search(query: String) {
        viewModel.searchQuery.value = query
 
        if let vc = self.childViewControllers.first as? AppRecommendationListViewController {
            vc.viewModel.searchQuery.value = query
        }
    }
    
    func setupTableView() {
        viewModel.appList
        .asObservable()
        .subscribe(onNext: {[weak self] (appList) in
            let newDataNum = self?.viewModel.appList.value.count ?? 0
            let oldDataNum = self?.loadedAppDetailCount ?? 0
            let diff = newDataNum - oldDataNum
            if diff > 0 {
                self?.tableView.beginUpdates()
                var paths = [IndexPath]()
                for idx in oldDataNum ..< newDataNum {
                    let indexPath = IndexPath(row: idx, section: 0)
                    paths.append(indexPath)
                }
                self?.tableView.insertRows(at: paths, with: .automatic)
                self?.tableView.endUpdates()
            } else {
                self?.tableView.reloadData()
            }
            self?.loadedAppDetailCount = newDataNum
        })
        .addDisposableTo(disposeBag)
        
        //load more
        tableView.rx.contentOffset
            .flatMap { [unowned self] (offset: CGPoint) -> Observable<Any> in
                if (AppListViewController.shouldLoadMore(contentOffset: offset, tableView: self.tableView)) {
                    return Observable.just(offset.y)
                } else {
                    return Observable.empty()
                }
            }
            .subscribe(onNext: {[unowned self] (originY) in
                self.viewModel.loadMore()
            }).addDisposableTo(disposeBag)
        
        //delegate
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        tableView.rx.setDataSource(self).addDisposableTo(disposeBag)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5,0.5,1)
        
        UIView.animate(withDuration: 0.25, delay: 0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
}

extension AppListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.appList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppListCell") as! AppListCell
        let row = indexPath.row
        let element = viewModel.appList.value[row]
        cell.lblIndex.text = String(row + 1)
        cell.lblTitle.text = element.name
        cell.lblCategory.text = element.category
        cell.ivIcon.layer.masksToBounds = true
        cell.ratingView.settings.updateOnTouch = false
        cell.ratingView.settings.fillMode = .half
        cell.ratingView.rating = Double(element.rating)
        cell.ratingView.text = "(\(element.ratingCount))"
        if let imageURL = element.imageURL, let url = URL(string: imageURL) {
            let image = UIImage(named: "default_profile_icon")
            cell.ivIcon.kf.setImage(with: url, placeholder: image)
        }
        if row % 2 == 0 {
            cell.ivIcon.layer.cornerRadius = 10
        } else {
            cell.ivIcon.layer.cornerRadius = cell.ivIcon.frame.size.width / 2
        }
        return cell
    }
}
