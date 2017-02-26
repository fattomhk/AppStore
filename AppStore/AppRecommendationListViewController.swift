//
//  AppRecommendationListViewController.swift
//  AppStore
//
//  Created by Horst 梁峻浩 on 23/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class AppRecommendationListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let disposeBag = DisposeBag()
    var viewModel: AppRecommendationStore = AppRecommendationStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setBottomBorder()
        
        viewModel.searchQuery.asObservable()
            .subscribe(onNext: {[weak self] (query) in
                self?.viewModel.search(by: query)
            })
            .addDisposableTo(disposeBag)
    }
    
    func setBottomBorder() {
        let bottomBorderLayerName = "bottomBorderLayer"
        if let layerToRemove = self.view.layer.sublayers?.filter({ (sublayer) -> Bool in
            return sublayer.name == bottomBorderLayerName
        }).first {
            layerToRemove.removeFromSuperlayer()
        }
        
        let bottom = CALayer()
        bottom.name = "bottomBorderLayer"
        bottom.frame = CGRect(x: 0, y: self.view.bounds.size.height - 0.5, width: self.view.bounds.size.width, height: 0.5)
        bottom.backgroundColor = UIColor.lightGray.cgColor
        self.view.layer.addSublayer(bottom)
    }
    
    func setupCollectionView() {
        viewModel.appRecommendationList
            .asObservable()
            .bindTo(collectionView.rx.items(cellIdentifier: "AppRecommendationCell", cellType: AppRecommendationCell.self)) {(row, element, cell) in
                cell.lblTitle.text = element.name
                cell.lblCategory.text = element.category
                cell.ivIcon.layer.masksToBounds = true
                
                if let imageURL = element.imageURL, let url = URL(string: imageURL) {
                    let image = UIImage(named: "default_profile_icon")
                    cell.ivIcon.kf.setImage(with: url, placeholder: image)
                }
                cell.ivIcon.layer.cornerRadius = 10
            }
            .addDisposableTo(disposeBag)
        
    }
}

