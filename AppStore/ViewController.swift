//
//  ViewController.swift
//  AppStore
//
//  Created by Horst Leung on 21/2/2017.
//  Copyright © 2017 Horst Leung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet weak var appListContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppListViewController") as? AppListViewController {
            self.addChildViewController(vc)
            vc.view.frame = appListContainer.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            appListContainer.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
        self.setupSearchBar()
        
        let tapReg = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapBackground))
        self.view.addGestureRecognizer(tapReg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSearchBar() {
        searchBar.rx.text.orEmpty
        .throttle(0.3, scheduler: MainScheduler.instance)
        .distinctUntilChanged()
        .debug("query")
        .subscribe(onNext: {[weak self] (query) in
            if let vc = self?.childViewControllers.first as? AppListViewController {
                vc.search(query: query)
            }
        }).addDisposableTo(disposeBag)
        
    }
    
    func didTapBackground() {
        self.view.endEditing(true)
    }

}

